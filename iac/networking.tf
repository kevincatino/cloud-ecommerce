module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24"]
  public_subnets  = []

  enable_nat_gateway = false
  enable_vpn_gateway = false
}

# Subnet Group for Aurora
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [module.vpc.private_subnets[2], module.vpc.private_subnets[3]]

  tags = {
    Name = "aurora-subnet-group"
  }
}

# Subnet Group for Aurora
resource "aws_db_subnet_group" "lambda_subnet_group" {
  name       = "lambda_subnet_group"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Name = "lambda_subnet_group"
  }
}