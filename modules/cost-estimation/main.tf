# ----
# AWS Pricing API lookups
#
# aws_pricing_product fails the plan unless its filters match exactly one product, so each
# lookup filters on regionCode plus attributes that are identical in every region. Validate
# new filters against the Pricing API in every supported region before adding them.
# ----

data "aws_pricing_product" "kms_keys" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AWSKMS"

  filters {
    field = "productFamily"
    value = "Encryption Key"
  }

  filters {
    field = "regionCode"
    value = var.region
  }
}

# S3 Standard storage (TimedStorage-ByteHrs), priced per GB-Mo
data "aws_pricing_product" "s3_storage" {
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
    field = "regionCode"
    value = var.region
  }
}

# S3 Standard PUT/COPY/POST/LIST requests (Requests-Tier1), priced per request
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
    field = "regionCode"
    value = var.region
  }
}

# S3 Standard GET and all other requests (Requests-Tier2), priced per request
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
    field = "regionCode"
    value = var.region
  }
}

# DynamoDB on-demand read request units, Standard table class (not IA)
data "aws_pricing_product" "dynamodb_read_requests" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonDynamoDB"

  filters {
    field = "productFamily"
    value = "Amazon DynamoDB PayPerRequest Throughput"
  }

  filters {
    field = "group"
    value = "DDB-ReadUnits"
  }

  filters {
    field = "regionCode"
    value = var.region
  }
}

# DynamoDB on-demand write request units, Standard table class
# (not DDB-ReplicatedWriteUnits, which bills global table replica writes)
data "aws_pricing_product" "dynamodb_write_requests" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonDynamoDB"

  filters {
    field = "productFamily"
    value = "Amazon DynamoDB PayPerRequest Throughput"
  }

  filters {
    field = "group"
    value = "DDB-WriteUnits"
  }

  filters {
    field = "regionCode"
    value = var.region
  }
}

# DynamoDB Standard table class storage, priced per GB-Mo
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
    field = "regionCode"
    value = var.region
  }
}

# Standard resolution metric alarms
data "aws_pricing_product" "cloudwatch_alarms" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonCloudWatch"

  filters {
    field = "productFamily"
    value = "Alarm"
  }

  filters {
    field = "group"
    value = "Alarm"
  }

  filters {
    field = "alarmType"
    value = "Standard"
  }

  filters {
    field = "regionCode"
    value = var.region
  }
}

# SNS publish API requests, priced per request
data "aws_pricing_product" "sns_requests" {
  count = local.pricing_enabled ? 1 : 0

  service_code = "AmazonSNS"

  filters {
    field = "productFamily"
    value = "API Request"
  }

  filters {
    field = "group"
    value = "SNS-Requests-Tier1"
  }

  filters {
    field = "regionCode"
    value = var.region
  }
}
