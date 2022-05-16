data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  name    = "eks-sandbox-vpc"
  cidr    = "10.9.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.9.1.0/24", "10.9.2.0/24"]
  public_subnets  = ["10.9.11.0/24", "10.9.12.0/24"]

  enable_nat_gateway = true

  tags = local.default_tags
}

module "eks_cluster" {
  source             = "../../modules/eks"
  vpc_id             = module.vpc.vpc_id
  cluster_name       = "eks-sandbox-cluster"
  cluster_version    = "1.20"
  subnet_ids         = module.vpc.private_subnets
  private_subnet_ids = module.vpc.private_subnets
  map_users          = var.map_users

  tags = local.default_tags
}