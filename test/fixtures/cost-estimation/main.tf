# Test fixture: plans the cost-estimation submodule in isolation with explicit quantities.
# The Pricing API is only available in us-east-1; region selects the prices to look up.
provider "aws" {
  region = "us-east-1"
}

module "cost_estimation" {
  source = "../../../modules/cost-estimation"

  enabled                              = var.enabled
  region                               = var.region
  kms_key_count                        = var.kms_key_count
  s3_storage_gb                        = var.s3_storage_gb
  s3_put_requests_monthly              = var.s3_put_requests_monthly
  s3_get_requests_monthly              = var.s3_get_requests_monthly
  dynamodb_read_request_units_monthly  = var.dynamodb_read_request_units_monthly
  dynamodb_write_request_units_monthly = var.dynamodb_write_request_units_monthly
  dynamodb_storage_gb                  = var.dynamodb_storage_gb
  cloudwatch_alarm_count               = var.cloudwatch_alarm_count
}
