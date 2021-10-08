module "main" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnets         = var.subnet_ids
  vpc_id          = var.vpc_id

  node_groups = {
    example = {
      target_group_arns = [aws_alb_target_group.tg.arn]
      subnets           = var.private_subnet_ids
      capacity_type     = "SPOT"
      instance_types    = ["t2.medium"]
      desired_capacity  = 2
      max_capacity      = 4
      min_capacity      = 1
    }
  }

  map_users = [
    for name in var.map_users :
    {
      groups = ["system:masters"]
      userarn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${name}"
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