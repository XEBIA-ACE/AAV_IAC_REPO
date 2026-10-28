output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate for the EKS cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL for the EKS cluster (for IAM roles for service accounts)"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "vpc_id" {
  description = "VPC ID used by the EKS cluster"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "node_group_name" {
  description = "EKS managed node group name"
  value       = aws_eks_node_group.this.node_group_name
}