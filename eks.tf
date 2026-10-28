resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30

  tags = var.tags
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.eks_version
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = concat([for s in aws_subnet.public : s.id], [for s in aws_subnet.private : s.id])
    endpoint_private_access = true
    endpoint_public_access  = var.enable_private_api ? false : true

    public_access_cidrs = var.enable_private_api ? [] : (
      length(var.allowed_admin_cidr_blocks) > 0 ? var.allowed_admin_cidr_blocks : ["0.0.0.0/0"]
    )
  }

  enabled_cluster_log_types = var.enable_cluster_logging ? [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ] : []

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceController,
    aws_cloudwatch_log_group.eks
  ]

  tags = var.tags
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [for s in aws_subnet.private : s.id]

  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"

  ami_type = "AL2_x86_64"

  disk_size = 50

  update_config {
    max_unavailable = 1
  }

  labels = {
    "workload"    = "medication-management"
    "environment" = var.environment
  }

  tags = merge(
    {
      "Name" = "${var.cluster_name}-default-ng"
    },
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly
  ]
}