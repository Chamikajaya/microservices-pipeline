terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "s3_backend" {
  source = "../modules/s3-backend"


  bucket_name          = "hiros-devops-microservices-tfstate-2024"
  dynamodb_table_name  = "terraform-locks-table"
  project_name         = "devops-microservices"
  environment          = "dev"
}

output "s3_bucket" {
  value = module.s3_backend.s3_bucket_id
}

output "dynamodb_table" {
  value = module.s3_backend.dynamodb_table_name
}

