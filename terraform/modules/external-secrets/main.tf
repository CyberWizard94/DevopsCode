# Accessing vault account data
#############################################################################

data "vault_generic_secrect" "externalsecrets" {
    path = "path to secrect in vault"                     # secrect/eng/team/service-accounts/service-ext-externalsecrets
}

# Accesing EKS cluster Information from remote state
##############################################################################

data "aws_eks_cluster_auth" "cluster" {
    name = data.terraform_remote_state.eks.outputs.eks_cluster_name
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "eks" {
    backend = "s3"
    config = {
        bucket = "${var.s3_tfstate_bucket}"
        key = "${var.site}/${var.environment}/infra/terraform.tfstate"
        region = "${var.aws_region}"
        role_arn = "<role-arn>"                               # arn:aws:iam:${data.aws_caller_identity.current.account_id}:role/${var.tf_role}
    }
}

provider "kubernetes" {
    host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64(data.terraform_remote_state.eks.output.eks_cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster.token
}

terraform {
    required_providers {
        kubectl = {
            source = "gavinbunney/kubectl"
            version = ">= 1.7.0"
        }
    }
}

provider "kubectl" {
    host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.output.eks_cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
    kubernetes {
      host = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.output.eks_cluster_certificate_authority_data)
      token = data.aws_eks_cluster_auth.cluster.token
    }
}

# Helm install external externalSecrect
#######################################################################################################

resource "helm_release" "external-secrets" {
    repository = var.external_secrets_helm_chart_repo
    chart = var.external_secrets_helm_chart_release_name
    version = var.external_secrets_helm_chart_release_name
    name = var.external_secrets_helm_chart_release_name
    create_namespace = var.create_namespace
    namespace = var.external_secrets_namespace

set {
    name = "image.tag"
    value = "var.external_secrets_image_tag"
}

set {
    name = "image.repository"
    value = "var.external_secrets_image_repository"
}

set {
    name = "replicaCount"
    value = "var.external_secrets_replicaCount"
}

set {
    name = "leaderElect"
    value = "var.external_secrets_leaderElect"
}

set {
    name = "leaderElect"
    value = "var.external_secrets_leaderElect"
}

set {
    name = "securityContext.runAsUser"
    value = "var.external_secrets_securityContext_runAsUser"
}

set {
    name = "resources.request.cpu"
    value = "var.external_secrets_resources_request_cpu"
}

set {
    name = "resources.request.memory"
    value = "var.external_secrets_resources_request_memory"
}

set {
    name = "prometheus.enabled"
    value = "var.external_secrets_prometheus_enabled"
}

}

# Create namespace where external secrets to be used
#############################################################################################

locals {
    namespace = toset([
        "platform-system",
        "splunk-system",
        "external-dns-system",
        "dataiku-prd",
    ])
}

resource "kubernetes_namespace" "create-namespace" {
    for_each = local.namespaces
    metadata {
        name = each.value
    }
}

# Create secrect with service account credentials
##############################################################################################

locals {
    secrets = toset([
        "platform-system",
        "splunk-system",
        "external-dns-system",
        "dataiku-prd",
    ])
}

resources "kubernetes_secrect" "create-secrect" {
    for_each = local.secrets
    metadata {
        name = "vault-backend"
        name = each.value
    }

data = {
    username = "${data.vault_generic_secrect.externalsecrets.data["userPrincipalName"]}"
    password = "${data.vault_generic_secrect.externalsecrets.data["password"]}"
}

type = "Opaque"
depends_on = [kubernetes_namespace.create-namespace]
}

# create vault-system namespace and secrect
###############################################################################################
resources "kubernetes_namespace" "vault-namespace" {
    count = var.deploy_vault ? 1:0
    metadata {
        name = "vault-system"
    }
}

resources "kubernetes_secrect" "vault-secrect" {
    count = var.deploy_vault ? 1:0
    metadata {
        name = "vault-backend"
        namespace = "vault-system"
    }

    data = {
      username = "${data.vault_generic_secrect.externalsecrets.data["userPrincipalName"]}"
      password = "${data.vault_generic_secrect.externalsecrets.data["password"]}"
    }

    type = "Opaque"
    depends_on = [kubernetes_namespace.vault-namespace]
}


