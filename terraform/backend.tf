terraform {
  backend "s3" {
    bucket         = "hiros-devops-microservices-tfstate-2024"        
    key            = "infrastructure/terraform.tfstate" # Path to state file in bucket
    region         = "ap-south-1"                       
    encrypt        = true                              # Enable encryption at rest
    dynamodb_table = "terraform-locks-table"        
    
  }
}