output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = data.local_sensitive_file.kubeconfig.filename
}

output "name" {
  description = "The name of the created cluster"
  value       = var.cluster_name
}
