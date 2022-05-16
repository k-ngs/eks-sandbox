module "main" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.21.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id

  eks_managed_node_groups = {
    example = {
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
    }
  }

  aws_auth_users = [
    for name in var.map_users :
    {
      groups   = ["system:masters"]
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${name}"
      username = name
    }
  ]

  tags = var.tags
}

resource "aws_alb_target_group" "tg" {
  name     = var.cluster_name
  port     = 30080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = var.tags
}