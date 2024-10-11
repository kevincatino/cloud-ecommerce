variable "region" {
  description = "Default region for provider"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the web application"
  type        = string
  default     = "web-app"
}

variable "environment_name" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "nextjs_export_directory" {
  description = "Static export directory of NextJS App"
  type        = string
  default     = "../frontend/out"
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "asdfkljh.com"
}

variable "db_name" {
  description = "Name of DB"
  type        = string
  default     = "inventory"
}

variable "db_user" {
  description = "Username for DB"
  type        = string
  default     = "userrrr"
}

variable "db_pass" {
  description = "Password for DB"
  type        = string
  sensitive   = true
  default     = "passssssss"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "cloud-ecommerce-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "cloud-pickup-ecommerce"
    Owner       = "kcatino@itba.edu.ar, acaeiro@itba.edu.ar, cditoro@itba.edu.ar, iszejer@itba.edu.ar"
  }
}

// TODO: usar terraform.tfvars sin pushear al repo para valores sensibles




