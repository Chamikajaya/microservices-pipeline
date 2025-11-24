# ----------------------------
# IAM Role for EKS Cluster
# ----------------------------
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-cluster-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

# ----------------------------
# IAM Role for Worker Nodes
# ----------------------------
resource "aws_iam_role" "eks_worker" {
  name = "${var.project_name}-${var.environment}-eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-worker-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Custom autoscaler policy
resource "aws_iam_policy" "autoscaler" {
  name        = "${var.project_name}-${var.environment}-eks-autoscaler-policy"
  description = "IAM policy for EKS cluster autoscaler"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      Effect   = "Allow",
      Resource = "*"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-autoscaler-policy"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach policies to worker role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.eks_worker.name
}

resource "aws_iam_role_policy_attachment" "autoscaler_policy" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.eks_worker.name
}

# Instance profile for worker nodes
resource "aws_iam_instance_profile" "eks_worker" {
  name = "${var.project_name}-${var.environment}-eks-worker-profile"
  role = aws_iam_role.eks_worker.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-eks-worker-profile"
    Environment = var.environment
    Project     = var.project_name
  }
}