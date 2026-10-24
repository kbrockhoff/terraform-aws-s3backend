output "policy_names" {
  description = "Map of deployer IAM policy names keyed by policy purpose"
  value       = module.deployer.policy_names
}
