data "local_file" "configuration" {
  filename = "${path.module}/values.tftpl.yaml"
}

resource "local_file" "configuration" {
  content = templatefile(data.local_file.configuration.filename, {
    kubernetes_version   = var.kubernetes_version,
    enable_telemetry     = var.enable_telemetry,
    enable_private_nodes = var.enable_private_nodes,
    enable_default_cni   = var.enable_default_cni,
    docker_nodes = [
      for i in range(var.worker_nodes) :
      "worker-${i + 1}"
    ]
  })
  filename = "${path.root}/values.yaml"
}

resource "terraform_data" "vind_cluster_apply" {
  triggers_replace = {
    config_change        = local_file.configuration.content_sha256
    kubeconfig_save_path = var.kubeconfig_save_path
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "#### Creating/upgrading vCluster with vind:" && \
      vcluster create ${var.cluster_name} -f "${path.root}/values.yaml" --upgrade && \
      vcluster connect ${var.cluster_name} --print > ${var.kubeconfig_save_path} && \
      echo "#### vCluster ${var.cluster_name} ready"
    EOT
  }
}

resource "terraform_data" "vind_cluster_destroy_hook" {
  input = {
    cluster_name         = var.cluster_name
    kubeconfig_save_path = var.kubeconfig_save_path
  }

  lifecycle {
    ignore_changes = [input]
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "#### Destroying vCluster with vind:" && \
      vcluster delete ${self.input.cluster_name} && \
      rm -f ${self.input.kubeconfig_save_path} && \
      echo "#### Cleanup completed"
    EOT
  }

  depends_on = [terraform_data.vind_cluster_apply]
}


data "local_sensitive_file" "kubeconfig" {
  filename = var.kubeconfig_save_path

  depends_on = [terraform_data.vind_cluster_apply]
}
