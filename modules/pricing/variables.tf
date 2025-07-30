variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "create_kms_key" {
  description = "Whether to create a KMS key for encryption"
  type        = bool
  default     = false
}

# S3 Configuration
variable "s3_storage_gb" {
  description = "Estimated S3 storage in GB per month for Terraform state files"
  type        = number
  default     = 1
}

variable "s3_put_requests_monthly" {
  description = "Estimated monthly S3 PUT/COPY/POST/LIST requests"
  type        = number
  default     = 100
}

variable "s3_get_requests_monthly" {
  description = "Estimated monthly S3 GET/SELECT requests"
  type        = number
  default     = 500
}

# DynamoDB Configuration
variable "dynamo_read_requests_monthly" {
  description = "Estimated monthly DynamoDB read requests for state locking"
  type        = number
  default     = 1000
}

variable "dynamo_write_requests_monthly" {
  description = "Estimated monthly DynamoDB write requests for state locking"
  type        = number
  default     = 500
}

variable "dynamo_storage_gb" {
  description = "Estimated DynamoDB storage in GB for state lock records"
  type        = number
  default     = 0.1
}

# CloudWatch Configuration
variable "cloudwatch_alarms_count" {
  description = "Number of CloudWatch alarms to create"
  type        = number
  default     = 5
}
