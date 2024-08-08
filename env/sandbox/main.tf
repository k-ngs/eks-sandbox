data "aws_caller_identity" "current" {}

locals {
  default_tags = {
    Env = "eks-sandbox"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"
  name    = "eks-sandbox"
  cidr    = "10.10.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.11.0/24", "10.10.12.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.20.0"
  cluster_name    = "eks-sandbox"
  cluster_version = "1.30"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  cluster_addons = {
    coredns = {
      resolve_conflicts = "NONE"
    }
    kube-proxy = {
      addon_name        = "kube-proxy"
      cluster_name      = module.eks.cluster_id
      resolve_conflicts = "NONE"
    }
    vpc-cni = {
      addon_name        = "vpc-cni"
      cluster_name      = module.eks.cluster_id
      resolve_conflicts = "NONE"
    }
  }

  eks_managed_node_groups = {
    default = {
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
      labels = {
        "workload" = "system"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API"
  cluster_endpoint_public_access           = true
}