module "vind_cluster" {
  source               = "../../modules/vind-cluster"
  cluster_name         = "local-cluster-istio"
  worker_nodes         = 3
  kubeconfig_save_path = "./kubeconfig"

  enable_default_cni = true
}

module "gateway" {
  source          = "../../modules/gateway_api"
  kubeconfig_path = module.vind_cluster.kubeconfig_path

  depends_on = [module.vind_cluster]
}

module "istio" {
  source     = "../../modules/istio-mesh"
  depends_on = [module.gateway]

  enable_ambient_mode = true
}
