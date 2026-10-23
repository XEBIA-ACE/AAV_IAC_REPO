# EKS cluster security group (for control plane -> node and API server access)
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.eks.id

  # EKS control plane egress to nodes and internet
  egress {
    description      = "Allow all egress from EKS control plane"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-cluster-sg"
  })
}

# Node group security group (for worker nodes)
resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.eks.id

  # Allow all egress from nodes (typical for EKS; tighten with egress rules if needed)
  egress {
    description      = "Allow all egress from nodes"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-nodes-sg"
  })
}

# Allow nodes to receive traffic from the cluster control plane
resource "aws_security_group_rule" "cluster_to_nodes" {
  description              = "Allow control plane to communicate with worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
}

# Allow nodes to receive pod traffic from itself / other nodes
resource "aws_security_group_rule" "nodes_to_nodes" {
  description       = "Allow node-to-node communication"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.eks.cidr_block]
  security_group_id = aws_security_group.eks_nodes.id
}

# (Optional) Allow API access to the EKS cluster from a specific CIDR (e.g., admin IPs)
variable "eks_api_allowed_cidrs" {
  description = "CIDR blocks allowed to access the EKS API server (public endpoint). Keep minimal or use VPN/Bastion."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}