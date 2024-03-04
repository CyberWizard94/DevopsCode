terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
        }
        kubectl = {
            source = "gavinbunney/kubectl"
        }
    }
}

provider "aws" {
    region = var.aws_region
    assume_role {
        role_arn = "<role arn >"                # role arn to connect to aws arn:aws:iam:<accountid>:role/<rolename>
    }
}

provider "vault" {
    address                   = var.vault_address
    namespace                 = "admin"
    skip_child_token          = true
    auth_login {
        path = "auth/approle/login"
        namespace = "admin"
        parameter = {
            role_id = "${var.app_role_id}"
            secret_id = "${var.app_secret_id}"
        }
    }
}

provider "kubernetes" {
    host                        = data.terraform_remote_state.eks.output.eks_cluster_endpoint
    cluster_ca_certificate      = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data)
    token                       = data.aws_eks_cluster_auth.cluster.token
}

provider "kubectl" {
    host                        = data.terraform_remote_state.eks.output.eks_cluster_endpoint
    cluster_ca_certificate      = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_certificate_authority_data)
    token                       = data.aws_eks_cluster_auth.cluster.token
    load_config_file            = false
}