locals {
  name   = "abhay-vpc"
  region = "us-east-2"

  tags = {
    Owner = "Abhay"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "10.16.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  private_subnets = ["10.16.16.0/24", "10.16.17.0/24"]
  public_subnets  = ["10.16.181.0/24", "10.16.182.0/24"]

  #enable_ipv6 = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "abhay-name-public"
  }

  tags = local.tags

  vpc_tags = {
    Name = "abhay-vpc"
  }
}
