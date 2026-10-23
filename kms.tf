# KMS key to encrypt EKS secrets and associated resources
resource "aws_kms_key" "eks" {
  description             = "KMS key for encrypting EKS secrets and related data"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-eks-kms"
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks"
  target_key_id = aws_kms_key.eks.id
}