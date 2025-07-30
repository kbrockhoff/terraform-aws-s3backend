# GitHub Actions OIDC Provider
data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enabled ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  count = var.enabled ? 1 : 0
  name  = "${var.name_prefix}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github_actions[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-actions"
  })
}

# IAM Policy Document for S3 Backend and Basic Terraform Operations
data "aws_iam_policy_document" "basic" {
  count = var.enabled ? 1 : 0

  # S3 Backend Operations
  statement {
    sid    = "TerraformStateS3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:${var.partition}:s3:::${var.s3_backend_bucket}",
      "arn:${var.partition}:s3:::${var.s3_backend_bucket}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [true]
    }
  }

  # DynamoDB State Locking
  statement {
    sid    = "TerraformStateLocking"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
    ]
    resources = [
      "arn:${var.partition}:dynamodb:${var.region}:${var.account_id}:table/${var.s3_backend_lock_table}"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  # Basic AWS API access for resource management
  statement {
    sid    = "BasicAWSAccess"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  # Pricing API access (required for cost estimation)
  statement {
    sid    = "PricingAPIAccess"
    effect = "Allow"
    actions = [
      "freetier:GetAccountPlanState",
      "pricing:GetAttributeValues",
      "pricing:GetProducts",
    ]
    resources = ["*"]
  }

}

# IAM Policy Document for Resource Management Operations
data "aws_iam_policy_document" "resource_management" {
  count = var.enabled ? 1 : 0

  # DynamoDB Operations
  statement {
    sid    = "DynamoDBResourceManagement"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
    ]
    resources = [
      "arn:${var.partition}:dynamodb:${var.region}:${var.account_id}:table/${var.name_prefix}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }

    # Restrict write operations to resources with specific name prefix
    condition {
      test     = "ForAllValues:StringLike"
      variable = "dynamodb:tablename"
      values   = ["${var.name_prefix}-*"]
    }
  }

  # KMS Operations
  statement {
    sid    = "KMSResourceManagement"
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:CreateGrant",
      "kms:CreateKey",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:EnableKeyRotation",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListResourceTags",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  # CloudWatch Operations
  statement {
    sid    = "CloudWatchResourceManagement"
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:PutMetricAlarm",
    ]
    resources = [
      "arn:${var.partition}:cloudwatch:${var.region}:${var.account_id}:alarm:${var.name_prefix}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }

  # Pricing API Operations
  statement {
    sid    = "PricingAPIResourceManagement"
    effect = "Allow"
    actions = [
      "pricelist:GetProducts",
    ]
    resources = ["*"]
  }

  # S3 Operations
  statement {
    sid    = "S3ResourceManagement"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucketEncryption",
      "s3:DeleteBucketLifecycle",
      "s3:DeleteBucketPublicAccessBlock",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCors",
      "s3:GetBucketEncryption",
      "s3:GetBucketLifecycle",
      "s3:GetBucketLogging",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketReplication",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:PutBucketEncryption",
      "s3:PutBucketLifecycle",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
    ]
    resources = [
      "arn:${var.partition}:s3:::${var.name_prefix}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [true]
    }

    # Restrict write operations to buckets with specific name prefix
    condition {
      test     = "ForAllValues:StringLike"
      variable = "s3:bucketname"
      values   = ["${var.name_prefix}-*"]
    }
  }

  # SNS Operations
  statement {
    sid    = "SNSResourceManagement"
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:GetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:SetTopicAttributes",
    ]
    resources = [
      "arn:${var.partition}:sns:${var.region}:${var.account_id}:${var.name_prefix}-*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }
}

# IAM Policy (standalone) - Basic
resource "aws_iam_policy" "basic" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-github-actions-basic"
  description = "Basic permissions for GitHub Actions CI/CD operations"
  policy      = data.aws_iam_policy_document.basic[0].json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-actions-basic"
  })
}

# IAM Policy (standalone) - Resource Management
resource "aws_iam_policy" "resource_management" {
  count       = var.enabled ? 1 : 0
  name        = "${var.name_prefix}-github-actions-resource-mgmt"
  description = "Resource management permissions for GitHub Actions CI/CD operations"
  policy      = data.aws_iam_policy_document.resource_management[0].json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-github-actions-resource-mgmt"
  })
}

# IAM Policy Attachment - Basic
resource "aws_iam_role_policy_attachment" "basic" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.basic[0].arn
}

# IAM Policy Attachment - Resource Management
resource "aws_iam_role_policy_attachment" "resource_management" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.resource_management[0].arn
}
