# ----
# Pricing Calculator
# ----

module "pricing" {
  source = "./modules/pricing"

  providers = {
    aws = aws.pricing
  }

  enabled        = var.enabled && var.cost_estimation_config.enabled
  region         = local.region
  create_kms_key = var.enabled && var.encryption_config.create_kms_key

  # S3 usage estimates
  s3_storage_gb           = 1   # 1GB for Terraform state files
  s3_put_requests_monthly = 600 # PUT/COPY/POST/LIST requests per month, including .tflock lock files
  s3_get_requests_monthly = 500 # GET/SELECT requests per month

  # DynamoDB usage estimates (zero unless the backward compatible lock table is created)
  dynamo_read_requests_monthly  = local.create_lock_table ? 1000 : 0 # Read requests for state locking
  dynamo_write_requests_monthly = local.create_lock_table ? 500 : 0  # Write requests for state locking
  dynamo_storage_gb             = local.create_lock_table ? 0.1 : 0  # Storage for lock records

  # CloudWatch usage estimates
  cloudwatch_alarms_count = local.effective_config.alarms_enabled ? (local.create_lock_table ? 5 : 3) : 0
}
