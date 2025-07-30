# Cost Estimation Terraform Module

Estimates the monthly cost of resources provisioned by the parent module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_cloudwatch_alarms_count"></a> [cloudwatch\_alarms\_count](#input\_cloudwatch\_alarms\_count) | Number of CloudWatch alarms to create | `number` | `5` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether to create a KMS key for encryption | `bool` | `false` | no |
| <a name="input_dynamo_read_requests_monthly"></a> [dynamo\_read\_requests\_monthly](#input\_dynamo\_read\_requests\_monthly) | Estimated monthly DynamoDB read requests for state locking | `number` | `1000` | no |
| <a name="input_dynamo_storage_gb"></a> [dynamo\_storage\_gb](#input\_dynamo\_storage\_gb) | Estimated DynamoDB storage in GB for state lock records | `number` | `0.1` | no |
| <a name="input_dynamo_write_requests_monthly"></a> [dynamo\_write\_requests\_monthly](#input\_dynamo\_write\_requests\_monthly) | Estimated monthly DynamoDB write requests for state locking | `number` | `500` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_s3_get_requests_monthly"></a> [s3\_get\_requests\_monthly](#input\_s3\_get\_requests\_monthly) | Estimated monthly S3 GET/SELECT requests | `number` | `500` | no |
| <a name="input_s3_put_requests_monthly"></a> [s3\_put\_requests\_monthly](#input\_s3\_put\_requests\_monthly) | Estimated monthly S3 PUT/COPY/POST/LIST requests | `number` | `100` | no |
| <a name="input_s3_storage_gb"></a> [s3\_storage\_gb](#input\_s3\_storage\_gb) | Estimated S3 storage in GB per month for Terraform state files | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Total estimated monthly cost in USD for module resources |
<!-- END_TF_DOCS -->    