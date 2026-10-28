terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.34"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }

  backend "s3" {
    bucket         = "ace-tfstate-119d9892-e900-49c1-a404-7cba440e2e72"
    key            = "eks/medication-management/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ace-tf-locks-119d9892-e900-49c1-a404-7cba440e2e72"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "ace"
      Project     = "119d9892-e900-49c1-a404-7cba440e2e72"
      Environment = var.environment
    }
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}