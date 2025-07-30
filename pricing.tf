# ----
# Pricing Calculator
# ----

module "pricing" {
  source = "./modules/pricing"

  providers = {
    aws = aws.pricing
  }

  enabled        = var.enabled && var.cost_estimation_enabled
  region         = local.region
  create_kms_key = var.enabled && var.create_kms_key

  # S3 usage estimates
  s3_storage_gb           = 1   # 1GB for Terraform state files
  s3_put_requests_monthly = 100 # PUT/COPY/POST/LIST requests per month
  s3_get_requests_monthly = 500 # GET/SELECT requests per month

  # DynamoDB usage estimates
  dynamo_read_requests_monthly  = 1000 # Read requests for state locking
  dynamo_write_requests_monthly = 500  # Write requests for state locking
  dynamo_storage_gb             = 0.1  # Storage for lock records

  # CloudWatch usage estimates
  cloudwatch_alarms_count = local.effective_config.alarms_enabled ? 5 : 0
}
