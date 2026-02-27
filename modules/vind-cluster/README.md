# vind-cluster

Module to create a new vCluster-in-Docker (VIND) Cluster, in a controller and (optional) multi-workers setup.

## Usage

Clone this repository and set the path to this module in your Project.

´´´hcl
module "vind_cluster" {
    source = "path/to/this/module"
    
    kubernetes_version = "1.35.1"
    cluster_name = "my_local_cluster"
    worker_nodes = 2 # Create two worker nodes
    kubeconfig_save_path = "./kubeconfig"
}
´´´

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0.0, < 3.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.configuration](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [terraform_data.kubeconfig](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.vind_cluster](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Defines the name of the cluster | `string` | `"local-cluster"` | no |
| <a name="input_enable_private_nodes"></a> [enable\_private\_nodes](#input\_enable\_private\_nodes) | Enable private nodes for the cluster. Requires Platform to be enabled | `bool` | `false` | no |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | Enable telemetry for the cluster | `bool` | `false` | no |
| <a name="input_kubeconfig_save_path"></a> [kubeconfig\_save\_path](#input\_kubeconfig\_save\_path) | Defines the path to save the kubeconfig file | `string` | `"kubeconfig"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Defines the kubernetes version to be used | `string` | `"v1.35.1"` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Defines the number of worker nodes to be created | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Path to the kubeconfig file |
| <a name="output_name"></a> [name](#output\_name) | The name of the created cluster |
<!-- END_TF_DOCS -->