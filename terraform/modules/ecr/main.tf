# ----------------------------
# ECR Repositories for Microservices
# ----------------------------
resource "aws_ecr_repository" "services" {
  for_each = toset(var.services)

  name                 = "${var.project_name}-${var.environment}-${each.value}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
  }

  # Delete all images before deleting the repository
  force_delete = var.force_delete

  tags = {
    Name        = "${var.project_name}-${var.environment}-${each.value}"
    Environment = var.environment
    Project     = var.project_name
    Service     = each.value
  }
}

# ----------------------------
# Lifecycle Policy for ECR Repositories
# ----------------------------
resource "aws_ecr_lifecycle_policy" "services" {
  for_each = var.enable_lifecycle_policy ? toset(var.services) : []

  repository = aws_ecr_repository.services[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
