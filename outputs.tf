# ----
# Primary resources IDs and names
# ----

output "s3_bucket_id" {
  description = "Name of the S3 bucket used for Terraform state storage"
  value       = var.enabled ? aws_s3_bucket.tfstate[0].id : ""
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state storage"
  value       = var.enabled ? aws_s3_bucket.tfstate[0].arn : ""
}

output "s3_bucket_region" {
  description = "AWS region where the S3 bucket is located"
  value       = var.enabled ? aws_s3_bucket.tfstate[0].region : ""
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = var.enabled ? aws_dynamodb_table.tfstate_lock[0].name : ""
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table used for Terraform state locking"
  value       = var.enabled ? aws_dynamodb_table.tfstate_lock[0].arn : ""
}

# ----
# Encryption
# ----

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = var.enabled && var.create_kms_key ? aws_kms_key.main[0].key_id : ""
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = local.kms_key_id
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = var.enabled && var.create_kms_key ? aws_kms_alias.main[0].name : ""
}

# ----
# Pricing
# ----

output "monthly_cost_estimate" {
  description = "Estimated monthly cost in USD for module resources"
  value       = module.pricing.monthly_cost_estimate
}

output "cost_breakdown" {
  description = "Detailed breakdown of monthly costs by service"
  value       = module.pricing.cost_breakdown
}
