variable "enabled" {
  description = "Set to false to skip the price lookups and return a zero estimate"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region where the parent module deploys its resources, e.g. us-west-2"
  type        = string
}

variable "kms_key_count" {
  description = "Number of KMS keys to include in cost estimation"
  type        = number
  default     = 0

  validation {
    condition     = var.kms_key_count >= 0
    error_message = "KMS key count must be zero or positive."
  }
}

variable "s3_storage_gb" {
  description = "Average S3 Standard storage in GB per month (state files and their versions)"
  type        = number
  default     = 0

  validation {
    condition     = var.s3_storage_gb >= 0
    error_message = "S3 storage must be zero or positive."
  }
}

variable "s3_put_requests_monthly" {
  description = "Monthly S3 PUT/COPY/POST/LIST requests, including .tflock lock file writes"
  type        = number
  default     = 0

  validation {
    condition     = var.s3_put_requests_monthly >= 0
    error_message = "S3 PUT request count must be zero or positive."
  }
}

variable "s3_get_requests_monthly" {
  description = "Monthly S3 GET and other requests"
  type        = number
  default     = 0

  validation {
    condition     = var.s3_get_requests_monthly >= 0
    error_message = "S3 GET request count must be zero or positive."
  }
}

variable "dynamodb_read_request_units_monthly" {
  description = "Monthly DynamoDB on-demand read request units for the legacy lock table (0 when no lock table is created)"
  type        = number
  default     = 0

  validation {
    condition     = var.dynamodb_read_request_units_monthly >= 0
    error_message = "DynamoDB read request units must be zero or positive."
  }
}

variable "dynamodb_write_request_units_monthly" {
  description = "Monthly DynamoDB on-demand write request units for the legacy lock table (0 when no lock table is created)"
  type        = number
  default     = 0

  validation {
    condition     = var.dynamodb_write_request_units_monthly >= 0
    error_message = "DynamoDB write request units must be zero or positive."
  }
}

variable "dynamodb_storage_gb" {
  description = "DynamoDB storage in GB for legacy lock records (0 when no lock table is created)"
  type        = number
  default     = 0

  validation {
    condition     = var.dynamodb_storage_gb >= 0
    error_message = "DynamoDB storage must be zero or positive."
  }
}

variable "cloudwatch_alarm_count" {
  description = "Number of CloudWatch alarms to include in cost estimation"
  type        = number
  default     = 0

  validation {
    condition     = var.cloudwatch_alarm_count >= 0
    error_message = "CloudWatch alarm count must be zero or positive."
  }
}
