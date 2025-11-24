output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.name
}

output "eks_worker_role_arn" {
  description = "ARN of the EKS worker node IAM role"
  value       = aws_iam_role.eks_worker.arn
}

output "eks_worker_role_name" {
  description = "Name of the EKS worker node IAM role"
  value       = aws_iam_role.eks_worker.name
}