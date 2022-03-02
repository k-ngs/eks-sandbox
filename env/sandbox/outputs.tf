output "aws_auth" {
  value = module.eks_cluster.aws_auth
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}