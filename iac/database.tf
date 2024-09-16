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

# Aurora PostgreSQL Cluster
resource "aws_rds_cluster" "aurora" {
  engine               = "aurora-postgresql"
  cluster_identifier   = "aurora-cluster"
  master_username      = var.db_user
  master_password      = var.db_pass
  database_name        = var.db_name
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  # Subnets for Aurora
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name

  tags = {
    Name = "aurora-cluster"
  }
}

# Aurora DB Instance
resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier        = "aurora-instance-1"
  engine = "postgres"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class    = "db.serverless"  # For Aurora Serverless v1 (use db.r6g for v2)
}

# Subnet Group for Aurora
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "aurora-subnet-group"
  }
}

resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "postgresql"
  instance_class       = "db.t3.micro"
  db_name                 = var.db_name
  username             = var.db_user
  password             = var.db_pass
  skip_final_snapshot  = true

  # Disable Enhanced Monitoring by setting monitoring_interval to 0
  monitoring_interval = 0

  # Other optional configurations...
  backup_retention_period = 7
  multi_az                = false
  storage_type            = "gp2"
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
