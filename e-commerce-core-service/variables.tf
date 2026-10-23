```hcl
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "ecommerce-core-cluster"
}

variable "node_group_name" {
  description = "The name of the worker nodes group"
  type        = string
  default     = "ecommerce-core-workers"
}

variable "node_instance_type" {
  description = "Instance type for the EKS cluster nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}
```