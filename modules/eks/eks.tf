module "main" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id
  enable_irsa = var.enable_irsa

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 4
      desired_size = 2

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
      tags = var.tags
    }
  }
  cluster_security_group_additional_rules = var.cluster_sg_additional_rules

  node_security_group_additional_rules = var.node_sg_additional_rules

  tags = var.tags
}

resource "aws_alb_target_group" "tg" {
  name     = var.cluster_name
  port     = 30080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = var.tags
}