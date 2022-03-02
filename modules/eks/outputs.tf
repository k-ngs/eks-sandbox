output "worker_iam_role_name" {
  value = module.main.eks_managed_node_groups["example"].iam_role_name
}

output "cluster_oidc_issuer_url" {
  value = module.main.cluster_oidc_issuer_url
}

output "cluster_endpoint" {
  value = module.main.cluster_endpoint
}

output "aws_auth" {
  value = module.main.aws_auth_configmap_yaml
}