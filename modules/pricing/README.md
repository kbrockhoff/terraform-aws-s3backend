# Cost Estimation Terraform Module

Estimates the monthly cost of resources provisioned by the parent module.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether to create a KMS key for encryption | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Total estimated monthly cost in USD for module resources |
<!-- END_TF_DOCS -->    