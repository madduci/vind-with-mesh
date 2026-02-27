# Creates a Namespace
resource "kubernetes_namespace_v1" "workshop" {
  metadata {
    name = "workshop"
    labels = {
      istio-injection = "enabled"
    }
  }

  depends_on = [module.istio]
}

# Wait for the cluster to be ready
resource "terraform_data" "example_deploy" {
  depends_on = [kubernetes_namespace_v1.workshop, terraform_data.gateway_apply]
  input = {
    kubeconfig_path  = module.vind_cluster.kubeconfig_path
    example_yaml     = "${path.root}/example.yaml"
    target_namespace = kubernetes_namespace_v1.workshop.metadata[0].name
  }

  // trigger again if the content changes
  triggers_replace = {
    hash = filesha256("${path.root}/example.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply --namespace ${self.input.target_namespace} -f ${self.input.example_yaml}"
    environment = {
      "KUBECONFIG" = self.input.kubeconfig_path
    }
  }
}

# Wait for the cluster to be ready
resource "terraform_data" "example_destroy" {
  input = {
    kubeconfig_path  = module.vind_cluster.kubeconfig_path
    example_yaml     = "${path.root}/example.yaml"
    target_namespace = kubernetes_namespace_v1.workshop.metadata[0].name
  }

  lifecycle {
    ignore_changes = [input]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete --namespace ${self.input.target_namespace} -f ${self.input.example_yaml}"
    environment = {
      "KUBECONFIG" = self.input.kubeconfig_path
    }
  }

  depends_on = [module.istio]
}
