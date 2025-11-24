# ----------------------------
# EKS Cluster
# ----------------------------
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-eks-cluster"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster"
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }

  depends_on = [var.cluster_role_arn]
}

# ----------------------------
# EKS Node Group
# ----------------------------
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-node-group"
  node_role_arn   = var.worker_role_arn
  subnet_ids      = var.node_group_subnet_ids

  capacity_type  = var.capacity_type
  disk_size      = var.disk_size
  instance_types = var.instance_types

  labels = {
    Environment = var.environment
    Project     = var.project_name
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-node-group"
    Environment = var.environment
    Project     = var.project_name
  }

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  depends_on = [var.worker_role_arn]
}

# ----------------------------
# OIDC Provider for ServiceAccount IAM Roles
# ----------------------------
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-oidc-provider"
    Environment = var.environment
    Project     = var.project_name
  }
}