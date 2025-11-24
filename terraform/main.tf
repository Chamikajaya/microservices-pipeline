terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module 
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
  environment          = var.environment
}

# EC2 Module 
module "ec2" {
  source = "./modules/ec2"

  vpc_id               = module.vpc.vpc_id
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  key_name             = var.key_name
  project_name         = var.project_name
  environment          = var.environment
  allowed_ssh_cidr     = var.allowed_ssh_cidr
}