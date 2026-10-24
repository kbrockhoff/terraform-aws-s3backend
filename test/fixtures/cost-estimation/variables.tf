variable "enabled" {
  description = "Set to false to prevent the module from looking up prices"
  type        = bool
  default     = true
}

variable "region" {
  description = "AWS region whose prices are looked up"
  type        = string
  default     = "us-west-2"
}

variable "kms_key_count" {
  description = "Number of KMS keys"
  type        = number
  default     = 0
}

variable "s3_storage_gb" {
  description = "S3 Standard storage in GB"
  type        = number
  default     = 0
}

variable "s3_put_requests_monthly" {
  description = "Monthly S3 PUT requests"
  type        = number
  default     = 0
}

variable "s3_get_requests_monthly" {
  description = "Monthly S3 GET requests"
  type        = number
  default     = 0
}

variable "dynamodb_read_request_units_monthly" {
  description = "Monthly DynamoDB read request units"
  type        = number
  default     = 0
}

variable "dynamodb_write_request_units_monthly" {
  description = "Monthly DynamoDB write request units"
  type        = number
  default     = 0
}

variable "dynamodb_storage_gb" {
  description = "DynamoDB storage in GB"
  type        = number
  default     = 0
}

variable "cloudwatch_alarm_count" {
  description = "Number of CloudWatch alarms"
  type        = number
  default     = 0
}
