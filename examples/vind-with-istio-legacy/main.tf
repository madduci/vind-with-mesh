module "vind_cluster" {
  source               = "../../modules/vind-cluster"
  cluster_name         = "local-cluster-istio"
  worker_nodes         = 3
  kubeconfig_save_path = "./kubeconfig"

  enable_default_cni = true
}

module "istio" {
  source     = "../../modules/istio-mesh"
  depends_on = [module.vind_cluster]

  enable_ambient_mode = false
}
