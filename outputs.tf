```hcl
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_id
}

output "kubeconfig" {
  description = "Kubeconfig file to access the cluster"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}
```

This configuration will set up a basic EKS cluster for development with auto-scalable nodes in a single availability zone to minimize costs. If you have any other specific requirements or need further customization, please let me know!