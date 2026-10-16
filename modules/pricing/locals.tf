# ----
# Pricing Calculator Local Values
# ----

locals {
  # Since we now use a dedicated provider that always points to us-east-1,
  # pricing API is always available when the module is enabled
  pricing_enabled = var.enabled

  # AWS Pricing API location names mapping
  # These are the location names as they appear in the AWS Pricing API
  region_location_map = {
    "af-south-1"     = "Africa (Cape Town)"
    "ap-east-1"      = "Asia Pacific (Hong Kong)"
    "ap-northeast-1" = "Asia Pacific (Tokyo)"
    "ap-northeast-2" = "Asia Pacific (Seoul)"
    "ap-northeast-3" = "Asia Pacific (Osaka)"
    "ap-south-1"     = "Asia Pacific (Mumbai)"
    "ap-south-2"     = "Asia Pacific (Hyderabad)"
    "ap-southeast-1" = "Asia Pacific (Singapore)"
    "ap-southeast-2" = "Asia Pacific (Sydney)"
    "ap-southeast-3" = "Asia Pacific (Jakarta)"
    "ap-southeast-4" = "Asia Pacific (Melbourne)"
    "ca-central-1"   = "Canada (Central)"
    "eu-central-1"   = "Europe (Frankfurt)"
    "eu-central-2"   = "Europe (Zurich)"
    "eu-north-1"     = "Europe (Stockholm)"
    "eu-south-1"     = "Europe (Milan)"
    "eu-south-2"     = "Europe (Spain)"
    "eu-west-1"      = "Europe (Ireland)"
    "eu-west-2"      = "Europe (London)"
    "eu-west-3"      = "Europe (Paris)"
    "il-central-1"   = "Israel (Tel Aviv)"
    "me-central-1"   = "Middle East (UAE)"
    "me-south-1"     = "Middle East (Bahrain)"
    "sa-east-1"      = "South America (Sao Paulo)"
    "us-east-1"      = "US East (N. Virginia)"
    "us-east-2"      = "US East (Ohio)"
    "us-west-1"      = "US West (N. California)"
    "us-west-2"      = "US West (Oregon)"
  }

  # Get the correct location name for pricing API queries
  pricing_location = lookup(local.region_location_map, var.region, "US East (N. Virginia)")

  # KMS pricing calculations
  kms_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.kms[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.kms[0].result).terms.OnDemand)
  ) : []
  kms_monthly = length(local.kms_on_demand) > 0 ? (
    values(local.kms_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "1.00"

  # S3 pricing calculations
  s3_storage_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.s3_standard_storage[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.s3_standard_storage[0].result).terms.OnDemand)
  ) : []
  s3_storage_monthly = length(local.s3_storage_on_demand) > 0 ? (
    values(local.s3_storage_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "0.023"

  s3_put_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.s3_put_requests[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.s3_put_requests[0].result).terms.OnDemand)
  ) : []
  s3_put_per_request = length(local.s3_put_on_demand) > 0 ? (
    values(local.s3_put_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "0.0005"

  s3_get_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.s3_get_requests[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.s3_get_requests[0].result).terms.OnDemand)
  ) : []
  s3_get_per_request = length(local.s3_get_on_demand) > 0 ? (
    values(local.s3_get_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "0.0004"

  # DynamoDB pricing calculations
  dynamo_read_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.dynamodb_read_requests[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.dynamodb_read_requests[0].result).terms.OnDemand)
  ) : []
  dynamo_read_per_request = length(local.dynamo_read_on_demand) > 0 ? (
    values(local.dynamo_read_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "0.00000025"

  dynamo_write_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.dynamodb_write_requests[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.dynamodb_write_requests[0].result).terms.OnDemand)
  ) : []
  dynamo_write_per_request = length(local.dynamo_write_on_demand) > 0 ? (
    values(local.dynamo_write_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "0.00000125"

  dynamo_storage_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.dynamodb_storage[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.dynamodb_storage[0].result).terms.OnDemand)
  ) : []
  dynamo_storage_monthly = length(local.dynamo_storage_on_demand) > 0 ? (
    values(local.dynamo_storage_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "0.25"

  # CloudWatch pricing calculations
  cloudwatch_alarms_on_demand = local.pricing_enabled && can(jsondecode(data.aws_pricing_product.cloudwatch_alarms[0].result).terms.OnDemand) ? (
    values(jsondecode(data.aws_pricing_product.cloudwatch_alarms[0].result).terms.OnDemand)
  ) : []
  cloudwatch_alarm_monthly = length(local.cloudwatch_alarms_on_demand) > 0 ? (
    values(local.cloudwatch_alarms_on_demand[0].priceDimensions)[0].pricePerUnit.USD
  ) : "0.10"

  # Total cost calculations
  costs = {
    kms_keys              = var.create_kms_key ? tonumber(local.kms_monthly) : 0
    s3_storage            = var.s3_storage_gb * tonumber(local.s3_storage_monthly)
    s3_put_requests       = (var.s3_put_requests_monthly / 1000) * tonumber(local.s3_put_per_request)
    s3_get_requests       = (var.s3_get_requests_monthly / 1000) * tonumber(local.s3_get_per_request)
    dynamo_read_requests  = var.dynamo_read_requests_monthly * tonumber(local.dynamo_read_per_request)
    dynamo_write_requests = var.dynamo_write_requests_monthly * tonumber(local.dynamo_write_per_request)
    dynamo_storage        = var.dynamo_storage_gb * tonumber(local.dynamo_storage_monthly)
    cloudwatch_alarms     = var.cloudwatch_alarms_count * tonumber(local.cloudwatch_alarm_monthly)
  }

  total_monthly_cost = (
    local.costs.kms_keys +
    local.costs.s3_storage +
    local.costs.s3_put_requests +
    local.costs.s3_get_requests +
    local.costs.dynamo_read_requests +
    local.costs.dynamo_write_requests +
    local.costs.dynamo_storage +
    local.costs.cloudwatch_alarms
  )
}
