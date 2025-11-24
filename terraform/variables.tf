variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "devops-microservices"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.large"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance (Amazon Linux 2023)"
  type        = string
  default     = "ami-02b8269d5e85954ef" 
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "devops-ms-nxv-kp"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (use your IP/32 for security)"
  type        = string
  default     = "0.0.0.0/0" 
}

# EKS Variables
variable "eks_kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.27"
}

variable "eks_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
  default     = ["t2.large"]
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes in EKS node group"
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes in EKS node group"
  type        = number
  default     = 10
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes in EKS node group"
  type        = number
  default     = 1
}

variable "eks_disk_size" {
  description = "Disk size in GiB for EKS worker nodes"
  type        = number
  default     = 20
}

# ECR Variables
variable "ecr_services" {
  description = "List of microservice names for ECR repositories"
  type        = list(string)
  default = [
    "emailservice",
    "checkoutservice",
    "recommendationservice",
    "frontend",
    "paymentservice",
    "productcatalogservice",
    "cartservice",
    "loadgenerator",
    "currencyservice",
    "shippingservice",
    "adservice"
  ]
}

variable "ecr_image_tag_mutability" {
  description = "Tag mutability setting for ECR repositories"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push for ECR repositories"
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "Encryption type for ECR repositories"
  type        = string
  default     = "AES256"
}

variable "ecr_force_delete" {
  description = "Delete all images before deleting ECR repositories"
  type        = bool
  default     = true
}

variable "ecr_enable_lifecycle_policy" {
  description = "Enable lifecycle policy for ECR repositories"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Maximum number of images to retain in ECR repositories"
  type        = number
  default     = 10
}
