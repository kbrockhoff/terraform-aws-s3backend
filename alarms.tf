# SNS Topic for alarm notifications (only created if no external topic provided)
resource "aws_sns_topic" "alarms" {
  count = local.create_sns_topic ? 1 : 0

  name              = "${local.name_prefix}-alarms"
  kms_master_key_id = local.kms_key_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alarms"
  })
}

# ----
# S3 Bucket CloudWatch Alarms
# ----

# S3 5xx Errors Alarm
resource "aws_cloudwatch_metric_alarm" "s3_5xx_errors" {
  count = var.enabled && local.effective_config.alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-s3-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5xxErrors"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors S3 5xx errors for ${aws_s3_bucket.tfstate[0].id}"
  alarm_actions       = [local.alarm_sns_topic_arn]
  ok_actions          = [local.alarm_sns_topic_arn]

  dimensions = {
    BucketName = aws_s3_bucket.tfstate[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-s3-5xx-errors"
  })
}

# S3 4xx Errors Alarm
resource "aws_cloudwatch_metric_alarm" "s3_4xx_errors" {
  count = var.enabled && local.effective_config.alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-s3-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors S3 4xx errors for ${aws_s3_bucket.tfstate[0].id}"
  alarm_actions       = [local.alarm_sns_topic_arn]
  ok_actions          = [local.alarm_sns_topic_arn]

  dimensions = {
    BucketName = aws_s3_bucket.tfstate[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-s3-4xx-errors"
  })
}

# S3 Bytes Downloaded Alarm (high usage indicator)
resource "aws_cloudwatch_metric_alarm" "s3_bytes_downloaded" {
  count = var.enabled && local.effective_config.alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-s3-bytes-downloaded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BytesDownloaded"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Sum"
  threshold           = "104857600" # 100 MB
  alarm_description   = "This metric monitors high S3 download activity for ${aws_s3_bucket.tfstate[0].id}"
  alarm_actions       = [local.alarm_sns_topic_arn]
  ok_actions          = [local.alarm_sns_topic_arn]

  dimensions = {
    BucketName = aws_s3_bucket.tfstate[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-s3-bytes-downloaded"
  })
}

# ----
# DynamoDB Table CloudWatch Alarms
# ----

# DynamoDB Read Throttling Alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttling" {
  count = var.enabled && local.effective_config.alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-dynamodb-read-throttling"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadThrottledEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB read throttling for ${aws_dynamodb_table.tfstate_lock[0].name}"
  alarm_actions       = [local.alarm_sns_topic_arn]
  ok_actions          = [local.alarm_sns_topic_arn]

  dimensions = {
    TableName = aws_dynamodb_table.tfstate_lock[0].name
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-dynamodb-read-throttling"
  })
}

# DynamoDB Write Throttling Alarm
resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttling" {
  count = var.enabled && local.effective_config.alarms_enabled ? 1 : 0

  alarm_name          = "${local.name_prefix}-dynamodb-write-throttling"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "WriteThrottledEvents"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB write throttling for ${aws_dynamodb_table.tfstate_lock[0].name}"
  alarm_actions       = [local.alarm_sns_topic_arn]
  ok_actions          = [local.alarm_sns_topic_arn]

  dimensions = {
    TableName = aws_dynamodb_table.tfstate_lock[0].name
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-dynamodb-write-throttling"
  })
}

