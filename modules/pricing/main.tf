# ----
# KMS Pricing Data
# ----

# KMS pricing
data "aws_pricing_product" "kms" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AWSKMS"

  filters {
    field = "productFamily"
    value = "Encryption Key"
  }

  filters {
    field = "usagetype"
    value = "${var.region}-KMS-Keys"
  }
}

# ----
# S3 Pricing Data
# ----

# S3 Standard Storage pricing
data "aws_pricing_product" "s3_standard_storage" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonS3"

  filters {
    field = "productFamily"
    value = "Storage"
  }

  filters {
    field = "storageClass"
    value = "General Purpose"
  }

  filters {
    field = "volumeType"
    value = "Standard"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}

# S3 PUT, COPY, POST, LIST requests pricing
data "aws_pricing_product" "s3_put_requests" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonS3"

  filters {
    field = "productFamily"
    value = "API Request"
  }

  filters {
    field = "groupDescription"
    value = "PUT/COPY/POST or LIST requests"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}

# S3 GET, SELECT requests pricing
data "aws_pricing_product" "s3_get_requests" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonS3"

  filters {
    field = "productFamily"
    value = "API Request"
  }

  filters {
    field = "groupDescription"
    value = "GET and all other requests"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}

# ----
# DynamoDB Pricing Data
# ----

# DynamoDB on-demand read requests
data "aws_pricing_product" "dynamodb_read_requests" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonDynamoDB"

  filters {
    field = "productFamily"
    value = "Amazon DynamoDB PayPerRequest Throughput"
  }

  filters {
    field = "usagetype"
    value = "ReadRequestUnits"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}

# DynamoDB on-demand write requests
data "aws_pricing_product" "dynamodb_write_requests" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonDynamoDB"

  filters {
    field = "productFamily"
    value = "Amazon DynamoDB PayPerRequest Throughput"
  }

  filters {
    field = "usagetype"
    value = "ReplWriteRequestUnits"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}

# DynamoDB data storage
data "aws_pricing_product" "dynamodb_storage" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonDynamoDB"

  filters {
    field = "productFamily"
    value = "Database Storage"
  }

  filters {
    field = "volumeType"
    value = "Amazon DynamoDB - Indexed DataStore"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}

# ----
# CloudWatch Pricing Data
# ----

# CloudWatch standard metrics
data "aws_pricing_product" "cloudwatch_metrics" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonCloudWatch"

  filters {
    field = "productFamily"
    value = "Metric"
  }

  filters {
    field = "usagetype"
    value = "${local.usagetype_region}-CW:MetricsUsage"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}

# CloudWatch alarms
data "aws_pricing_product" "cloudwatch_alarms" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonCloudWatch"

  filters {
    field = "productFamily"
    value = "Alarm"
  }

  filters {
    field = "usagetype"
    value = "CW:AlarmMonitorUsage"
  }

  filters {
    field = "location"
    value = local.pricing_location
  }
}
