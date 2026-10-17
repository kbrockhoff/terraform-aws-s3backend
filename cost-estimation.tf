# ----
# Pricing Calculator
# ----

module "pricing" {
  source = "./modules/cost-estimation"

  providers = {
    aws = aws.pricing
  }

  enabled       = var.enabled && var.cost_estimation_config.enabled
  region        = local.region
  kms_key_count = var.enabled && var.encryption_config.create_kms_key ? 1 : 0

  # S3 usage assumptions
  s3_storage_gb           = var.enabled ? var.cost_estimation_config.s3_storage_gb : 0
  s3_put_requests_monthly = var.enabled ? var.cost_estimation_config.s3_put_requests_monthly : 0
  s3_get_requests_monthly = var.enabled ? var.cost_estimation_config.s3_get_requests_monthly : 0

  # DynamoDB usage assumptions (zero unless the backward compatible lock table is created)
  dynamodb_read_request_units_monthly  = local.create_lock_table ? var.cost_estimation_config.dynamodb_read_request_units_monthly : 0
  dynamodb_write_request_units_monthly = local.create_lock_table ? var.cost_estimation_config.dynamodb_write_request_units_monthly : 0
  dynamodb_storage_gb                  = local.create_lock_table ? var.cost_estimation_config.dynamodb_storage_gb : 0

  # 3 S3 alarms, plus 2 DynamoDB throttling alarms when the lock table exists
  cloudwatch_alarm_count = var.enabled && local.effective_config.alarms_enabled ? (local.create_lock_table ? 5 : 3) : 0
}
