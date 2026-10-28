variable "aws_region" {
  description = "AWS region to deploy EKS into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "medication-mgmt-eks"
}

variable "vpc_cidr" {
  description = "CIDR block for the new VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Instance types for EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "enable_cluster_logging" {
  description = "Enable EKS control plane logging to CloudWatch"
  type        = bool
  default     = true
}

variable "allowed_admin_cidr_blocks" {
  description = "CIDR blocks allowed to access the EKS cluster API (in addition to cluster nodes)"
  type        = list(string)
  default     = []
}

variable "enable_private_api" {
  description = "Whether to enable private endpoint access only (true) or public+private (false)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}