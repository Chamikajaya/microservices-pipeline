variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "services" {
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

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for ECR repositories (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS key ARN for ECR encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "force_delete" {
  description = "Delete all images before deleting the repository"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for ECR repositories"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to retain in ECR repository"
  type        = number
  default     = 10
}

variable "enable_cross_account_access" {
  description = "Enable cross-account access to ECR repositories"
  type        = bool
  default     = false
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to pull images"
  type        = list(string)
  default     = []
}