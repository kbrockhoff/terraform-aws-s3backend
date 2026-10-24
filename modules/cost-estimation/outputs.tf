output "monthly_cost_estimate" {
  description = "Total estimated monthly cost in USD for module resources"
  value       = local.pricing_enabled ? local.total_monthly_cost : 0
}

output "cost_breakdown" {
  description = "Estimated monthly cost in USD by component, e.g. kms_keys, s3_storage, cloudwatch_alarms"
  value       = local.pricing_enabled ? local.costs : {}
}
