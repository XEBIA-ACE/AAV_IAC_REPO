```hcl
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 17.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    eks_nodes = {
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_size
      min_capacity     = var.min_size

      instance_type = var.node_instance_type
    }
  }

  tags = {
    Name = "e-commerce-core-service-eks"
    Project = "6f2fbdc5-d238-42ca-93ca-888e3233a026"
    Environment = "dev"
  }
}
```