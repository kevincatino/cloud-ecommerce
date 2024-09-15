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

# Setup db schema
resource "null_resource" "trigger_migration" {
  provisioner "local-exec" {
    command = "aws lambda invoke --function-name index /dev/null"
  }

  depends_on = [aws_lambda_function.api_action]
}
