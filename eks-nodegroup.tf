# IAM role for EKS worker nodes (managed node group)
resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# KMS permissions for node role to use the EKS key (least-privilege)
data "aws_iam_policy_document" "eks_kms_node_access" {
  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = [
      aws_kms_key.eks.arn
    ]
  }
}

resource "aws_iam_policy" "eks_kms_node_access" {
  name   = "${var.cluster_name}-eks-kms-node-access"
  policy = data.aws_iam_policy_document.eks_kms_node_access.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_node_kms" {
  role       = aws_iam_role.eks_node.name
  policy_arn = aws_iam_policy.eks_kms_node_access.arn
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = [for s in aws_subnet.private : s.id]

  scaling_config {
    desired_size = var.node_group_desired_size
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  capacity_type = local.is_prod ? "ON_DEMAND" : "SPOT"

  update_config {
    max_unavailable = 1
  }

  ami_type = "AL2_x86_64"

  remote_access {
    ec2_ssh_key = null
  }

  labels = {
    "app.kubernetes.io/component" = "worker"
    "project"                     = var.project_id
    "environment"                 = var.environment
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-ng"
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_kms
  ]
}