output "eks_cluster_name" {
    value = module.eksCluster.aws_eks_cluster_name
}

output "eks_cluster_endpoint" {
    value = module.eksCluster.eks_cluster_endpoint
}

output "eks_cluster_ca_certificate" {
    value = module.eksCluster.eks_cluster_certificate_authority_data
}

output "eks_iam_openid_connect_provider_arn" {
    value = module.eksCluster.aws_iam_openid_connect_provider_arn
}

output "eks_cluster_iam_opeid_extract_arn" {
    value = module.eksCluster.aws_iam_openid_connect_provider_extract_from_arn
}