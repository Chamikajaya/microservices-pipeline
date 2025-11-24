terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
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

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  instance_type    = var.instance_type
  ami_id           = var.ami_id
  key_name         = var.key_name
  project_name     = var.project_name
  environment      = var.environment
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# IAM Module for EKS
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  project_name     = var.project_name
  environment      = var.environment
  cluster_role_arn = module.iam.eks_cluster_role_arn
  worker_role_arn  = module.iam.eks_worker_role_arn

  # Use public subnets for EKS cluster
  subnet_ids            = module.vpc.public_subnet_ids
  node_group_subnet_ids = module.vpc.public_subnet_ids

  kubernetes_version = var.eks_kubernetes_version
  instance_types     = var.eks_instance_types
  desired_size       = var.eks_desired_size
  max_size           = var.eks_max_size
  min_size           = var.eks_min_size
  disk_size          = var.eks_disk_size

  depends_on = [module.iam]
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  services     = var.ecr_services

  # ECR Configuration
  image_tag_mutability     = var.ecr_image_tag_mutability
  scan_on_push             = var.ecr_scan_on_push
  encryption_type          = var.ecr_encryption_type
  force_delete             = var.ecr_force_delete
  enable_lifecycle_policy  = var.ecr_enable_lifecycle_policy
  max_image_count          = var.ecr_max_image_count
  enable_cross_account_access = var.ecr_enable_cross_account_access
  allowed_account_ids      = var.ecr_allowed_account_ids
}