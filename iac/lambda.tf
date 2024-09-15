data "archive_file" "lambda" {
  for_each    = fileset("${path.module}/files", "*.js")
  type        = "zip"
  source_file = "files/${each.value}"
  output_path = "files/${split(".", each.value)[0]}.zip"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "api_action" {
  for_each      = fileset("${path.module}/files", "*.zip")
  function_name = split(".", each.value)[0]
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  filename      = "files/${each.value}"
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

  vpc_config {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  depends_on = [aws_rds_cluster.aurora]
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
