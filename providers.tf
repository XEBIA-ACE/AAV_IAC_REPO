variable "aws_region" {
  description = "AWS region to deploy the EKS cluster into"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}