output "monthly_cost_estimate" {
  description = "Total estimated monthly cost in USD"
  value       = module.cost_estimation.monthly_cost_estimate
}

output "cost_breakdown" {
  description = "Monthly cost in USD by component"
  value       = module.cost_estimation.cost_breakdown
}
