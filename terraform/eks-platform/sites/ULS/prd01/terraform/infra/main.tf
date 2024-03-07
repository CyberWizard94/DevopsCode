module "eksCluster" {
    source                               = "../../../../../modules/eks"
    vpc_id                               = var.vpc_id
    environment                          = var.environment
    eks_cluster_name                     = var.eks_cluster_name
    eks_master_role_name                 = var.eks_master_role_name
    cluster_version                      = var.cluster_version
    eks_subnet_ids                       = var.eks_subnet_ids
    cluster_endpoint_private_access      = var.cluster_endpoint_private_access
    cluster_endpoint_public_access       = var.cluster_endpoint_public_access
    cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
    cluster_service_ipv4_cidr            = var.cluster_service_ipv4_cidr
    cluster_enabled_log_types            = var.cluster_enabled_log_types
    cluster_enabled_log_types            = var.cluster_enabled_log_types

    #node group1
    node_group1_subnet_ids               = var.node_group1_subnet_ids
    node_group1_cluster_version          = var.node_group1_cluster_version
    node_group1_ec2_ssh_key              = var.node_group1_ec2_ssh_key
    node_group1_security_group           = var.node_group2_security_group
    node_group1_ami_type                 = var.node_group1_ami_type
    node_group1_capacity_type            = var.node_group1_capacity_type
    node_group1_disk_size                = var.node_group1_disk_size
    node_group1_instance_type            = var.node_group1_instance_type
    node_group1_desired_size             = var.node_group1_desired_size
    node_group1_min_size                 = var.node_group1_min_size
    node_group1_max_size                 = var.node_group1_max_size
    node_group1_max_unavailable          = var.node_group1_max_unavailable

    #node_group2

    node_group2_subnet_ids               = var.node_group2_subnet_ids
    node_group2_cluster_version          = var.node_group2_cluster_version
    node_group2_ec2_ssh_key              = var.node_group2_ec2_ssh_key
    node_group2_security_group           = var.node_group2_security_group
    node_group2_ami_type                 = var.node_group2_ami_type
    node_group2_capacity_type            = var.node_group2_capacity_type
    node_group2_disk_size                = var.node_group2_disk_size
    node_group2_instance_type            = var.node_group2_instance_type
    node_group2_desired_size             = var.node_group2_desired_size
    node_group2_min_size                 = var.node_group2_min_size
    node_group2_max_size                 = var.node_group2_max_size
    node_group2_max_unavailable          = var.node_group2_max_unavailable
}

module "external-secrects" {
    source                               = "../../../../../modules/external-secrects"
    ou                                   = var.ou
    application                          = var.application
    site                                 = var.site
    environment                          = var.environment
    name                                 = var.name
    owner                                = var.owner
    eks_cluster_name                     = var.eks_cluster_name
    aws_region                           = var.aws_region
    account_id                           = var.account_id
    s3_tfstate_bucket                    = var.s3_tfstate_bucket
    deploy_vault                         = var.deploy_vault
    tf_role                              = var.tf_role
}