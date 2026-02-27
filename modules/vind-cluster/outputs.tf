output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = var.kubeconfig_save_path
}

output "name" {
  description = "The name of the created cluster"
  value       = var.cluster_name
}
