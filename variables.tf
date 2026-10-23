```hcl
variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "e-commerce-core-service-cluster"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 3
}
```