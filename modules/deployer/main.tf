# ----
# Least privilege permissions to provision and deprovision the parent module's resources.
# Terraform state backend access is granted by terraform-aws-cicdrole, not here.
#
# This module IS the state backend: the tfstate bucket, the optional lock table, the KMS key,
# the alarms and the SNS topic are its own resources, so this policy manages them (create,
# configure, delete) but grants no state object read/write or lock item access.
# ----

data "aws_iam_policy_document" "main" {
  count = var.enabled ? 1 : 0

  # Caller identity lookups used by the parent module's data sources
  statement {
    sid    = "CallerIdentity"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  # Pricing API access (required for cost estimation)
  statement {
    sid    = "PricingRead"
    effect = "Allow"
    actions = [
      "freetier:GetAccountPlanState",
      "pricing:GetAttributeValues",
      "pricing:GetProducts",
    ]
    resources = ["*"]
  }

  # State bucket and its configuration resources (no object access)
  statement {
    sid    = "S3BucketManagement"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLogging",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutEncryptionConfiguration",
      "s3:PutLifecycleConfiguration",
    ]
    resources = [
      "arn:${var.partition}:s3:::${local.state_bucket_name}",
    ]
  }

  # Deprecated DynamoDB lock table, only created with backward_compatibility_enabled (no item access)
  dynamic "statement" {
    for_each = var.backward_compatibility_enabled ? [local.lock_table_name] : []
    content {
      sid    = "DynamoDBTableManagement"
      effect = "Allow"
      actions = [
        "dynamodb:CreateTable",
        "dynamodb:DeleteTable",
        "dynamodb:DescribeContinuousBackups",
        "dynamodb:DescribeTable",
        "dynamodb:DescribeTimeToLive",
        "dynamodb:ListTagsOfResource",
        "dynamodb:TagResource",
        "dynamodb:UntagResource",
        "dynamodb:UpdateTable",
      ]
      resources = [
        "arn:${var.partition}:dynamodb:${var.region}:${var.account_id}:table/${statement.value}",
      ]
    }
  }

  # KMS actions which do not support resource-level permissions
  statement {
    sid    = "KmsGlobal"
    effect = "Allow"
    actions = [
      "kms:CreateKey",
      "kms:ListAliases",
      "kms:ListKeys",
    ]
    resources = ["*"]
  }

  # Key IDs are AWS-generated, so keys are scoped to the account/region. Also covers the
  # grants DynamoDB creates when the lock table is encrypted with the key.
  statement {
    sid    = "KmsKeyManagement"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:EnableKeyRotation",
      "kms:GenerateDataKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListGrants",
      "kms:ListResourceTags",
      "kms:PutKeyPolicy",
      "kms:RetireGrant",
      "kms:RevokeGrant",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:UpdateKeyDescription",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]
  }

  # Key deletion only on the module's own key, identified by its Name tag
  statement {
    sid    = "KmsKeyDeletion"
    effect = "Allow"
    actions = [
      "kms:ScheduleKeyDeletion",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Name"
      values   = ["${var.name_prefix}-cmk"]
    }
  }

  # Alias management requires permission on both the alias and the target key
  statement {
    sid    = "KmsAliasManagement"
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:UpdateAlias",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:alias/${var.name_prefix}-cmk",
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]
  }

  statement {
    sid    = "AlarmManagement"
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
    ]
    resources = [
      "arn:${var.partition}:cloudwatch:${var.region}:${var.account_id}:alarm:${var.name_prefix}-*",
    ]
  }

  statement {
    sid    = "TopicManagement"
    effect = "Allow"
    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:GetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
    ]
    resources = [
      "arn:${var.partition}:sns:${var.region}:${var.account_id}:${var.name_prefix}-alarms",
    ]
  }
}

resource "aws_iam_policy" "this" {
  for_each = local.policy_documents

  name        = "${local.policy_name_prefix}-${each.key}"
  description = "Least privilege permissions for CI/CD to deploy the ${local.module_short_name} module (${each.key})"
  policy      = each.value

  tags = merge(var.tags, {
    Name = "${local.policy_name_prefix}-${each.key}"
  })
}

# Optional attachment, e.g. to the role created by terraform-aws-cicdrole
resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.attach_to_role ? aws_iam_policy.this : {}

  role       = var.iam_role_name
  policy_arn = each.value.arn
}
