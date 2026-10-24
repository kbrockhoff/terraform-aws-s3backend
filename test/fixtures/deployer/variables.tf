variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Organization unique prefix to use for resource names"
  type        = string
}

variable "iam_role_name" {
  description = "Name of an existing IAM role to attach the policies to"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region where the parent module is deployed"
  type        = string
  default     = "us-west-2"
}

variable "account_id" {
  description = "AWS account ID where the parent module is deployed"
  type        = string
  default     = "123456789012"
}

variable "backward_compatibility_enabled" {
  description = "Set to true to also grant management of the deprecated DynamoDB lock table"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "ARN of an existing KMS key used by the parent module"
  type        = string
  default     = ""
}
