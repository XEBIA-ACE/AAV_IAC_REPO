# Core cluster addons with encryption and observability in mind

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "vpc-cni"
  resolve_conflicts        = "OVERWRITE"
  preserve                 = true
  addon_version            = "v1.18.2-eksbuild.3"

  tags = var.tags
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"
  preserve          = true
  addon_version     = "v1.11.1-eksbuild.4"

  tags = var.tags
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
  preserve          = true
  addon_version     = "v1.30.0-eksbuild.1"

  tags = var.tags
}

# (Optional) AWS EBS CSI driver for dynamic, encrypted volumes
resource "aws_eks_addon" "ebs_csi" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "aws-ebs-csi-driver"
  resolve_conflicts = "OVERWRITE"
  preserve          = true

  tags = var.tags
}