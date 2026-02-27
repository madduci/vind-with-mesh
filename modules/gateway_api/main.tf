locals {
  gateway_api_url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.release_version}/standard-install.yaml"
}

resource "terraform_data" "gateway_api_deploy" {
  input = {
    gateway_api_url = local.gateway_api_url
    kubeconfig_path = var.kubeconfig_path
  }

  triggers_replace = {
    on_version_change = var.release_version
    gateway_api_url   = local.gateway_api_url
    kubeconfig_path   = var.kubeconfig_path
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${local.gateway_api_url} --kubeconfig=${var.kubeconfig_path}"
    environment = {
      "KUBECONFIG" = var.kubeconfig_path
    }
  }
}

resource "terraform_data" "gateway_api_destroy" {
  input = {
    gateway_api_url = local.gateway_api_url
    kubeconfig_path = var.kubeconfig_path
  }

  lifecycle {
    ignore_changes = [input]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ${self.input.gateway_api_url} --kubeconfig=${self.input.kubeconfig_path} --ignore-not-found=true"
    environment = {
      "KUBECONFIG" = self.input.kubeconfig_path
    }
  }
}
