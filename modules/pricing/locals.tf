# ----
# Pricing Calculator Local Values
# ----

locals {
  # AWS Pricing API is only available in specific regions
  # See: https://docs.aws.amazon.com/general/latest/gr/billing.html
  # Note: This module now uses a dedicated provider that always points to us-east-1
  pricing_api_supported_regions = [
    "us-east-1",
    "ap-south-1"
  ]

  # Since we now use a dedicated provider that always points to us-east-1,
  # pricing API is always available when the module is enabled
  pricing_enabled = var.enabled

  usagetype_region_map = {
    "af-south-1"     = "AFS1"
    "ap-east-1"      = "APE1"
    "ap-east-2"      = "APE2"
    "ap-northeast-1" = "APN1"
    "ap-northeast-2" = "APN2"
    "ap-northeast-3" = "APN3"
    "ap-south-1"     = "APS1"
    "ap-south-2"     = "APS2"
    "ap-southeast-1" = "APS3"
    "ap-southeast-2" = "APS4"
    "ap-southeast-3" = "APS5"
    "ap-southeast-4" = "APS6"
    "ap-southeast-5" = "APS7"
    "ap-southeast-7" = "APS9"
    "ca-central-1"   = "CAN1"
    "ca-west-1"      = "CAN2"
    "cn-north-1"     = "CNN1"
    "cn-northwest-1" = "CNNW1"
    "eu-central-1"   = "EUC1"
    "eu-central-2"   = "EUC2"
    "eu-north-1"     = "EUN1"
    "eu-south-1"     = "EUS1"
    "eu-south-2"     = "EUS2"
    "eu-west-1"      = "EU"
    "eu-west-2"      = "EUW2"
    "eu-west-3"      = "EUW3"
    "il-central-1"   = "ILC1"
    "me-central-1"   = "MEC1"
    "me-south-1"     = "MES1"
    "mx-central-1"   = "MXC1"
    "sa-east-1"      = "SAE1"
    "us-gov-east-1"  = "UGE1"
    "us-gov-west-1"  = "UGW1"
    "us-east-1"      = "USE1"
    "us-east-2"      = "USE2"
    "us-west-1"      = "USW1"
    "us-west-2"      = "USW2"
  }

  usagetype_region = lookup(local.usagetype_region_map, var.region, "USE1")

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
