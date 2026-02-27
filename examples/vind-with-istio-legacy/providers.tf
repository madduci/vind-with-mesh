terraform {
  required_version = ">= 1.6.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = module.vind_cluster.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = module.vind_cluster.kubeconfig_path
}