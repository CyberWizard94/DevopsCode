variable "ou" {
    description = "A prefix used for naming resources"
    type = string
}

variable "site" {
    type = string
}

variable "application" {
    description = ""
    type = string
}

variable "s3_tfstate_bucket" {
    description = ""
    type = string
}

variable "environment" {
    description = ""
    type = string
}

variable "name" {
    description = ""
    type = string
}

variable "tf_role" {
    description = ""
    type = string
}

variable "owner" {
    description = ""
    type = string
}

variable "enabled" {
    description = "Variable indicating whether deployment is enabled"
    type = bool
    default = true
}

variable "account_id" {
    description = ""
    type = string
}

variable "eks_cluster_name" {
    description = "The name of the cluster"
    type = string
}

variable "aws_region" {
    description = "The region for secrect store logs"
    type = string
}

variable "external_secrets_helm_chart_repo" {
    description = "External Secret helm chart repo"
    type = string
    default = "https://charts.external-secret.io"
}

variable "external_secrets_helm_chart_release_name" {
    description = "External Secret helm chart release_name"
    type = string
    default = "external-secrets"
}

variable "external_secrets_helm_chart_version" {
    description = "External Secret helm chart version"
    type = string
    default = "0.9.2"
}

variable "external_secrets_helm_chart_name" {
    description = "External Secret helm chart name"
    type = string
    default = "external-secret"
}

variable "external_secrets_namespace" {
    description = "External Secret helm chart namespace"
    type = string
    default = "external-secret"
}

variable "external_secrets_image_repository" {
    description = "External Secret image repository"
    type = string
    default = "ghcr.io/external-secrect/external-secrets"
}

variable "external_secrets_image_tag" {
    description = "External Secret image tag"
    type = string
    default = "v0.7.2"
}

variable "external_secrets_replicaCount" {
    description = "External Secret replicCount"
    type = bool
    default = "2"
}

variable "external_secrets_securityContext_runAsNonRoot" {
    description = "External Secret securityContext runAsNonRoot"
    type = bool
    default = "true"
}


variable "external_secrets_securityContext_runAsUser" {
    description = "External Secret securityContext runAsUser"
    type = string
    default = "1000"
}

variable "external_secrets_resources_requests_cpu" {
    description = "External Secret resources requests cpu"
    type = string
    default = "10m"
}

variable "external_secrets_resources_requests_memory" {
    description = "External Secret resources requests memory"
    type = string
    default = "32Mi"
}

variable "external_secrets_prometheus_enabled" {
    description = "External Secret prometheus enabled"
    type = bool
    default = true
}

variable "create_namespace" {
    description = "whether ot not to create namespace if namespace does not exist"
    type = bool
    default = true
}

variable "deploy_vault" {
    description = "create vault system namespace and secrect"
    type = bool
    default = false
}



