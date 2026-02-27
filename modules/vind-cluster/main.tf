data "local_file" "configuration" {
  filename = "${path.module}/values.tftpl.yaml"
}

resource "local_file" "configuration" {
  content = templatefile(data.local_file.configuration.filename, {
    kubernetes_version   = var.kubernetes_version,
    enable_telemetry     = var.enable_telemetry,
    enable_private_nodes = var.enable_private_nodes,
    docker_nodes = [
      for i in range(var.worker_nodes) :
      "worker-${i + 1}"
    ]
  })
  filename = "${path.module}/values.yaml"
}

resource "terraform_data" "vind_cluster" {
  input = {
    cluster_name = var.cluster_name
  }

  triggers_replace = {
    config_change = local_file.configuration.content_sha256
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "#### Creating a new vCluster with vind:" && \
      vcluster create ${var.cluster_name} -f "${path.module}/values.yaml" --upgrade && \
      echo "#### vCluster ${var.cluster_name} created successfully"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo "#### Destroying the vCluster with vind:" && \
      vcluster delete ${self.input.cluster_name} && \
      echo "#### vCluster ${self.input.cluster_name} destroyed successfully"
    EOT
  }
}

resource "terraform_data" "kubeconfig" {
  input = {
    kubeconfig_save_path = var.kubeconfig_save_path
  }

  triggers_replace = {
    config_change = local_file.configuration.content_sha256
  }

  provisioner "local-exec" {
    command = <<EOT
      vcluster connect ${var.cluster_name} --print > ${var.kubeconfig_save_path} && echo "#### Kubeconfig saved to ${var.kubeconfig_save_path}"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      rm -f ${self.input.kubeconfig_save_path} && echo "#### Kubeconfig ${self.input.kubeconfig_save_path} destroyed successfully"
    EOT
  }

  depends_on = [terraform_data.vind_cluster]
}
