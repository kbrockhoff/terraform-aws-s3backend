# ----
# Least privilege permissions to provision and deprovision the parent module's resources.
# Terraform state backend access is granted by terraform-aws-cicdrole, not here.
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

  # KMS actions which do not support resource-level permissions
  statement {
    sid    = "KmsList"
    effect = "Allow"
    actions = [
      "kms:ListAliases",
      "kms:ListKeys",
    ]
    resources = ["*"]
  }

  # Key creation only when the new key is tagged as the module's key
  statement {
    sid    = "KmsKeyCreate"
    effect = "Allow"
    actions = [
      "kms:CreateKey",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"
      values   = [local.kms_key_name]
    }
  }

  # Tag-on-create: the key has no Name tag yet and the request sets it to the module's key name
  statement {
    sid    = "KmsKeyTagOnCreate"
    effect = "Allow"
    actions = [
      "kms:TagResource",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Name"
      values   = [local.kms_key_name]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/Name"
      values   = ["true"]
    }
  }

  # Key IDs are AWS-generated, so keys are scoped to the account/region. Reads are unconditioned
  # so refresh does not depend on tag propagation.
  statement {
    sid    = "KmsKeyRead"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListGrants",
      "kms:ListResourceTags",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]
  }

  # Changes to existing keys only on the module's own key, identified by its Name tag
  statement {
    sid    = "KmsKeyManagement"
    effect = "Allow"
    actions = [
      "kms:CancelKeyDeletion",
      "kms:CreateGrant",
      "kms:DisableKey",
      "kms:DisableKeyRotation",
      "kms:EnableKey",
      "kms:EnableKeyRotation",
      "kms:PutKeyPolicy",
      "kms:RetireGrant",
      "kms:RevokeGrant",
      "kms:ScheduleKeyDeletion",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Name"
      values   = [local.kms_key_name]
    }
  }

  # Tag changes on the module's own key, which can neither change nor remove its Name tag
  statement {
    sid    = "KmsKeyTagging"
    effect = "Allow"
    actions = [
      "kms:TagResource",
      "kms:UntagResource",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Name"
      values   = [local.kms_key_name]
    }

    condition {
      test     = "ForAllValues:StringNotEquals"
      variable = "aws:TagKeys"
      values   = ["Name"]
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
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:alias/${local.kms_key_name}",
    ]
  }

  statement {
    sid    = "KmsAliasTargetKey"
    effect = "Allow"
    actions = [
      "kms:CreateAlias",
      "kms:DeleteAlias",
      "kms:UpdateAlias",
    ]
    resources = [
      "arn:${var.partition}:kms:${var.region}:${var.account_id}:key/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Name"
      values   = [local.kms_key_name]
    }
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
      "arn:${var.partition}:sns:${var.region}:${var.account_id}:${var.name_prefix}-*",
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
