# gateway-api

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [terraform_data.gateway_api_deploy](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.gateway_api_destroy](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubeconfig_path"></a> [kubeconfig\_path](#input\_kubeconfig\_path) | Path to the kubeconfig file | `string` | n/a | yes |
| <a name="input_release_version"></a> [release\_version](#input\_release\_version) | The version of the release to deploy | `string` | `"v1.4.1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_version"></a> [gateway\_version](#output\_gateway\_version) | The version of the Gateway API CRDs deployed |
<!-- END_TF_DOCS -->