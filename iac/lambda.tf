resource "null_resource" "npm_install_schema" {
  for_each = fileset("${path.module}/lambda/schema", "*/*.js")
  provisioner "local-exec" {
    command = "cd lambda/schema/${split("/", each.value)[0]} && npm i"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "null_resource" "npm_install_action" {
  for_each = fileset("${path.module}/lambda/api", "*/*.js")
  provisioner "local-exec" {
    command = "cd lambda/api/${split("/", each.value)[0]} && npm i"
  }

  triggers = {
    always_run = timestamp()
  }
}

data "archive_file" "schema_lambda" {
  # for_each    = fileset("${path.module}/lambda/schema", "*/*.js")
  type        = "zip"
  source_dir = "lambda/schema/generate_schema"
  output_path = "lambda/schema/generate_schema.zip"
}

data "archive_file" "api_lambda" {
  for_each    = fileset("${path.module}/lambda/api", "*/*.js")
  type        = "zip"
  source_dir = "lambda/api/${split("/", each.value)[0]}"
  output_path = "lambda/api/${split("/", each.value)[0]}.zip"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "schema_action" {
  function_name = "generate_schema"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
    filename      = "lambda/schema/generate_schema.zip"
  source_code_hash = data.archive_file.schema_lambda.output_base64sha256
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole" // usamos LabRole porque no podemos crear roles o adjuntar policies

  environment {
    variables = {
      DB_HOST     = aws_rds_cluster.aurora.endpoint
      DB_PORT     = "5432"
      DB_NAME     = var.db_name
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_pass
    }
  }

  timeout       = 15  

  vpc_config {
    subnet_ids         = aws_db_subnet_group.lambda_subnet_group.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_rds_cluster.aurora, data.archive_file.schema_lambda]
}

resource "aws_lambda_function" "api_action" {
  for_each      = data.archive_file.api_lambda
  function_name = split("/", each.key)[0]
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  filename      = "lambda/api/${split("/", each.key)[0]}.zip"
  source_code_hash = data.archive_file.api_lambda[each.key].output_base64sha256

  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole" // usamos LabRole porque no podemos crear roles o adjuntar policies

  timeout       = 15  

  environment {
    variables = {
      DB_HOST     = aws_rds_cluster.aurora.endpoint
      DB_PORT     = "5432"
      DB_NAME     = var.db_name
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_pass
    }
  }

  vpc_config {
    subnet_ids         = aws_db_subnet_group.lambda_subnet_group.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_rds_cluster.aurora, data.archive_file.api_lambda]
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-security-group"
  description = "Security group for Lambda functions connecting to Aurora"
  vpc_id      = module.vpc.vpc_id

  # Outbound rules to allow Lambda to connect to Aurora on PostgreSQL (5432) or MySQL (3306)
  egress {
    from_port   = 5432  # or 3306 if using MySQL
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to any destination
  }
}
