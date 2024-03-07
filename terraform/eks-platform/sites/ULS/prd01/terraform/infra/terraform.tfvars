#generic
 
 ou                                         = "eng"
 aws_region                                 = "us-west-2"
 application                                = "aws-platform"
 environment                                = "prd01"
 name                                       = "aws-platform"
 owner                                      = "<owner name>"
 account_id                                 = "<account_id>"
 site                                       = "<site name>"
 vpc_id                                     = "<vpc_id>"
 s3_tfstate_bucket                          = "<s3 bucket name>"
 vault_address                              = "<vault url>"
 tf_role                                    = "<role name>"


 #eks cluster

 eks_cluster_name                           = "<cluster name>"
 eks_master_role_name                       = "<eks master role>"
 cluster_version                            = "<eks cluster version>"
 eks_subnet_ids                             = "[<subnet_ids>]"
 cluster_endpoint_private_access            = true
 cluster_endpoint_public_access             = false
 cluster_endpoint_public_access_cidrs       = ["0.0.0.0/0"]
 cluster_service_ipv4_cidr                  = "<service cidr>"
 cluster_enabled_log_types                  = ["api", "audit", "authenticator", "controllerManager", "Scheduler"]
 tags                                       = {<tags for resources>}
 node_group1_security_group                 = "<cluster security group>"

 #node group 1

node_group1_subnet_ids               = [<subnet ids for nodegroup>]
node_group1_cluster_version          = "1.25"
node_group1_ec2_ssh_key              = "<ssh keys>"
node_group1_ami_type                 = "<ami type>"
node_group1_capacity_type            = "ON_DEMAND"
node_group1_disk_size                = <disk size>
node_group1_instance_type            = [<instance size>]
node_group1_desired_size             = <desired size of node group>
node_group1_min_size                 = <min size of node group>
node_group1_max_size                 = <max size of node group>
node_group1_max_unavailable          = <max unavailable size of node group>

 #node group 2

node_group2_subnet_ids               = [<subnet ids for nodegroup>]
node_group2_cluster_version          = "1.25"
node_group2_ec2_ssh_key              = "<ssh keys>"
node_group2_ami_type                 = "<ami type>"
node_group2_capacity_type            = "ON_DEMAND"
node_group2_disk_size                = <disk size>
node_group2_instance_type            = [<instance size>]
node_group2_desired_size             = <desired size of node group>
node_group2_min_size                 = <min size of node group>
node_group2_max_size                 = <max size of node group>
node_group2_max_unavailable          = <max unavailable size of node group>


#custom networking

secondary_cidr                       = "100.64.128.0/188"
secondary_subnets                    = { Secondary second subnets}

#external secrects
deploy_vault                         = true

#aws load balancer controller

aws_lb_helm_version                  = "1.6.2"

