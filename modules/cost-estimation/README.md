# Cost Estimation Terraform Module

Estimates the monthly on-demand cost in USD of the resources the parent S3 backend module
provisions, using live prices from the AWS Pricing API.

The parent passes a provider pinned to `us-east-1`, where the Pricing API is available, and the
`region` it deploys to. Each price is looked up by `regionCode` with filters validated to match
exactly one product in every region.

## Components

- `kms_keys`: customer managed KMS key, per key-month.
- `s3_storage`: S3 Standard storage, per GB-month.
- `s3_put_requests` / `s3_get_requests`: S3 Standard request charges, per request.
- `dynamodb_read_requests` / `dynamodb_write_requests` / `dynamodb_storage`: the on-demand
  legacy lock table, only when it is created (`backward_compatibility_enabled`).
- `cloudwatch_alarms`: standard resolution metric alarms, per alarm-month.
- `sns_requests`: SNS publishes for alarm notifications.

## Assumptions

- On-demand prices only; no Savings Plans, Reserved capacity or account free tiers.
- Tiered prices use the lowest paid tier. DynamoDB storage therefore ignores the 25 GB free
  tier, and S3 storage uses the first 50 TB tier.
- S3 and DynamoDB usage (storage GB, requests and request units per month) is an assumption
  supplied by the parent through `cost_estimation_config`; the parent defaults are 1 GB, 600
  PUT/LIST and 500 GET requests, and for the lock table 1000 read units, 500 write units and
  0.1 GB.
- SSE-KMS request charges are not estimated; the bucket uses S3 Bucket Keys, which keep them
  negligible.
- SNS requests assume one notification per alarm per day (30 per month).
- If a price can't be parsed, a us-east-1 default is used instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.69.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the parent module deploys its resources, e.g. us-west-2 | `string` | n/a | yes |
| <a name="input_cloudwatch_alarm_count"></a> [cloudwatch\_alarm\_count](#input\_cloudwatch\_alarm\_count) | Number of CloudWatch alarms to include in cost estimation | `number` | `0` | no |
| <a name="input_dynamodb_read_request_units_monthly"></a> [dynamodb\_read\_request\_units\_monthly](#input\_dynamodb\_read\_request\_units\_monthly) | Monthly DynamoDB on-demand read request units for the legacy lock table (0 when no lock table is created) | `number` | `0` | no |
| <a name="input_dynamodb_storage_gb"></a> [dynamodb\_storage\_gb](#input\_dynamodb\_storage\_gb) | DynamoDB storage in GB for legacy lock records (0 when no lock table is created) | `number` | `0` | no |
| <a name="input_dynamodb_write_request_units_monthly"></a> [dynamodb\_write\_request\_units\_monthly](#input\_dynamodb\_write\_request\_units\_monthly) | Monthly DynamoDB on-demand write request units for the legacy lock table (0 when no lock table is created) | `number` | `0` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_kms_key_count"></a> [kms\_key\_count](#input\_kms\_key\_count) | Number of KMS keys to include in cost estimation | `number` | `0` | no |
| <a name="input_s3_get_requests_monthly"></a> [s3\_get\_requests\_monthly](#input\_s3\_get\_requests\_monthly) | Monthly S3 GET and other requests | `number` | `0` | no |
| <a name="input_s3_put_requests_monthly"></a> [s3\_put\_requests\_monthly](#input\_s3\_put\_requests\_monthly) | Monthly S3 PUT/COPY/POST/LIST requests, including .tflock lock file writes | `number` | `0` | no |
| <a name="input_s3_storage_gb"></a> [s3\_storage\_gb](#input\_s3\_storage\_gb) | Average S3 Standard storage in GB per month (state files and their versions) | `number` | `0` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cost_breakdown"></a> [cost\_breakdown](#output\_cost\_breakdown) | Detailed breakdown of monthly costs by service |
| <a name="output_monthly_cost_estimate"></a> [monthly\_cost\_estimate](#output\_monthly\_cost\_estimate) | Total estimated monthly cost in USD for module resources |
<!-- END_TF_DOCS -->    