output "repository_urls" {
  description = "Map of service names to ECR repository URLs"
  value = {
    for service, repo in aws_ecr_repository.services :
    service => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of service names to ECR repository ARNs"
  value = {
    for service, repo in aws_ecr_repository.services :
    service => repo.arn
  }
}

output "repository_names" {
  description = "Map of service names to ECR repository names"
  value = {
    for service, repo in aws_ecr_repository.services :
    service => repo.name
  }
}

output "registry_id" {
  description = "Registry ID (AWS account ID)"
  value       = values(aws_ecr_repository.services)[0].registry_id
}

output "repository_list" {
  description = "List of all ECR repository URLs"
  value       = [for repo in aws_ecr_repository.services : repo.repository_url]
}