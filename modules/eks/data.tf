data "aws_eks_cluster" "cluster" {
  name = module.main.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.main.cluster_id
}

data "aws_caller_identity" "current" {}