output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = terraform_data.kubeconfig.triggers_replace.kubeconfig_path
}

output "name" {
  description = "The name of the created cluster"
  value       = var.cluster_name
}
