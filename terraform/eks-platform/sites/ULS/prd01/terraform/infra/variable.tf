variable "aws_region" {
    type         = string
}

variable "account_id" {
    type         = string
}

variable "ou" {
    description  = "A prefix used for naming resources"
    type         = string
}

variable "site" {
    type         = string
}

variable "s3_tfstate_bucket" {
    type         = string
}

variable "application" {
    type         = string
}

variable "environment" {
    type         = string
}

variable "name" {
    type         = string
}

variable "owner" {
    type         = string
}

variable "vpc_id" {
    type         = string
}

variable "vault_address" {
    type         = string
}

variable "app_role_id" {
    type         = string
}

variable "app_secret_id" {
    type         = string
}

variable "tf_role" {
    type         = string
}

variable "cluster_name" {
    description  = "Name of eks cluster"
    type         = string
}

variable "eks_master_role_name" {
    description  = "Name of eks cluster"
    type         = string
}

variable "cluster_version" {
    description  = "Name of eks cluster"
    type         = string
}

variable "eks_subnet_ids" {
    description  = "Name of eks cluster"
    type         = list(string)
    default      = []
}

variable "node_group1_ec2_ssh_key" {
    description  = "Name of eks cluster"
    type         = string
}

variable "cluster_endpoint_private_access" {
    type         = bool
}

variable "cluster_endpoint_public_access" {
    type         = bool
}

variable "cluster_endpoint_public_access_cidrs" {
    type         = bool
}

variable "cluster_name" {
    description  = "Name of eks cluster"
    type         = list(string)
}

variable "cluster_service_ipv4_cidr" {
    type         = string
}

variable "cluster_enabled_log_types" {
    type         = list(string)
}

variable "tags" {
    type         = map(string)
}

###############################################################################################
#Node Group Name 1
###############################################################################################

variable "node_group1_security_group" {
    type         = string
}

variable "node_group1_subnet_ids" {
    type         = list(string)
}

variable "node_group1_cluster_version" {
    type         = string
}

variable "node_group1_ami_type" {
    type         = string
}

variable "node_group1_capacity_type" {
    type         = string
}

variable "node_group1_disk_size" {
    type         = string
}

variable "node_group1_instance_type" {
    type         = list(string)
}

variable "node_group1_desired_size" {
    type         = string
}

variable "node_group1_min_size" {
    type         = string
}

variable "node_group1_max_size" {
    type         = string
}

variable "node_group1_max_unavailable" {
    type         = string
}

###############################################################################################
#Node Group Name 2
###############################################################################################

variable "node_group2_security_group" {
    type         = string
}

variable "node_group2_subnet_ids" {
    type         = list(string)
}

variable "node_group2_cluster_version" {
    type         = string
}

variable "node_group2_ami_type" {
    type         = string
}

variable "node_group2_capacity_type" {
    type         = string
}

variable "node_group2_disk_size" {
    type         = string
}

variable "node_group2_instance_type" {
    type         = list(string)
}

variable "node_group2_desired_size" {
    type         = string
}

variable "node_group2_min_size" {
    type         = string
}

variable "node_group2_max_size" {
    type         = string
}

variable "node_group2_max_unavailable" {
    type         = string
}

# CUSTOM networking
##########################################################################################

variable "secondary_cidr" {
    description = "The second CIDR block to associate with the vpc, must be /16 division or higher"
    type = string
}

variable "secondary_subnets" {
    description = "A map where the key is the name of the availibility zone and the value is the subnet CIDR"
}

#External secrets
############################################################################################
variable "deploy_vault" {
    type = bool
    description = "Create vault system namespace and secrect"
}

variable "aws_alb_helm_version" {
    type = string
}