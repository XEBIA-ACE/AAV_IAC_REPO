```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "e-commerce-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  public_subnets  = ["10.0.1.0/24"]
  enable_dns_hostnames = true

  tags = {
    Name = "e-commerce-vpc"
    Project = "6f2fbdc5-d238-42ca-93ca-888e3233a026"
    Environment = "dev"
  }
}
```