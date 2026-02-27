# Creates a Namespace for the Gateway
resource "kubernetes_namespace_v1" "ingress" {
  metadata {
    name = "istio-ingress"
  }

  depends_on = [module.istio]
}

# Wait for the cluster to be ready
resource "terraform_data" "install_gateway" {
  input = {
    kubeconfig_path  = module.vind_cluster.kubeconfig_path
    gateway_yaml     = "${path.root}/gateway.yaml"
    target_namespace = kubernetes_namespace_v1.ingress.metadata[0].name
  }

  // trigger again if the content changes
  triggers_replace = {
    hash = filesha256("${path.root}/gateway.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply --namespace ${self.input.target_namespace} -f ${self.input.gateway_yaml}"
    environment = {
      "KUBECONFIG" = self.input.kubeconfig_path
    }
  }

  depends_on = [kubernetes_namespace_v1.ingress]
}

# Wait for the cluster to be ready
resource "terraform_data" "remove_gateway" {
  depends_on = [terraform_data.install_gateway]
  input = {
    kubeconfig_path  = module.vind_cluster.kubeconfig_path
    gateway_yaml     = "${path.root}/gateway.yaml"
    target_namespace = kubernetes_namespace_v1.ingress.metadata[0].name
  }

  lifecycle {
    ignore_changes = [input]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete --namespace ${self.input.target_namespace} -f ${self.input.gateway_yaml}"
    environment = {
      "KUBECONFIG" = self.input.kubeconfig_path
    }
  }
}
