```hcl
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "eks_vpc"
    Environment = "development"
    ManagedBy   = "ace"
  }
}

resource "aws_subnet" "eks_subnet" {
  count = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name        = "eks_subnet_${count.index}"
    Environment = "development"
    ManagedBy   = "ace"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }

  tags = {
    Name        = var.cluster_name
    Environment = "development"
    ManagedBy   = "ace"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "eks-service-role"
    Environment = "development"
    ManagedBy   = "ace"
  }
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_role.name
}
```