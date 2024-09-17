resource "aws_security_group" "aurora_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow Lambda to connect"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aurora-sg"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora_parameter_group" {
  name   = "rds-pgroup"
  family = "aurora-postgresql11"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

# Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "aurora" {
  engine               = "aurora-postgresql"
  engine_mode = "serverless"
  cluster_identifier   = "aurora-cluster"
  master_username      = var.db_user
  master_password      = var.db_pass
  database_name        = var.db_name
  enable_http_endpoint    = true
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  # Subnets for Aurora
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name

  scaling_configuration {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 4
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  depends_on = [
    aws_security_group.aurora_sg,
    aws_db_subnet_group.aurora_subnet_group,
    aws_rds_cluster_parameter_group.aurora_parameter_group,
  ]

  tags = {
    Name = "aurora-cluster"
  }
}

# # Aurora DB Instance
# resource "aws_rds_cluster_instance" "aurora_instance" {
#   identifier        = "aurora-instance-1"
#   engine = "postgres"
#   cluster_identifier = aws_rds_cluster.aurora.id
#   instance_class    = "db.serverless"  # For Aurora Serverless v1 (use db.r6g for v2)
# }

# Subnet Group for Aurora
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "aurora-subnet-group"
  }
}

# Setup db schema
resource "aws_lambda_invocation" "invoke_generate_schema" {
  function_name = aws_lambda_function.schema_action.function_name

  # Optional: Pass a payload to the Lambda function (in JSON format)
  input = jsonencode({
    "action" : "generate_schema"
  })

  # You can reference this output as needed in your Terraform config
  depends_on = [aws_lambda_function.schema_action]
}
