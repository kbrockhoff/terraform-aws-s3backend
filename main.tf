# ----
# S3 Backend Resources
# ----

# S3 Bucket for Terraform state storage
resource "aws_s3_bucket" "tfstate" {
  count = var.enabled ? 1 : 0

  bucket = "${local.name_prefix}-tfstate-${local.account_id}"

  tags = merge(local.common_data_tags, {
    Name = "${local.name_prefix}-tfstate-${local.account_id}"
  })
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "tfstate" {
  count = var.enabled ? 1 : 0

  bucket = aws_s3_bucket.tfstate[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  count = var.enabled ? 1 : 0

  bucket = aws_s3_bucket.tfstate[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_id
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "tfstate" {
  count = var.enabled ? 1 : 0

  bucket = aws_s3_bucket.tfstate[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket policy to require secure transport
resource "aws_s3_bucket_policy" "tfstate" {
  count = var.enabled ? 1 : 0

  bucket = aws_s3_bucket.tfstate[0].id
  policy = data.aws_iam_policy_document.tfstate_bucket_policy[0].json
}

# IAM policy document for S3 bucket policy
data "aws_iam_policy_document" "tfstate_bucket_policy" {
  count = var.enabled ? 1 : 0

  # Require secure transport (HTTPS)
  statement {
    sid    = "DenyInsecureConnections"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.tfstate[0].arn,
      "${aws_s3_bucket.tfstate[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Deny unencrypted object uploads
  statement {
    sid    = "DenyUnencryptedObjectUploads"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.tfstate[0].arn}/*"]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "tfstate_lock" {
  count = var.enabled ? 1 : 0

  name         = "${local.name_prefix}-tfstate-${local.account_id}-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = local.kms_key_id
  }

  tags = merge(local.common_data_tags, {
    Name = "${local.name_prefix}-tfstate-${local.account_id}-lock"
  })
}

# S3 Bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  count = var.enabled ? 1 : 0

  bucket = aws_s3_bucket.tfstate[0].id

  rule {
    id     = "terraform_state_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Transition non-current versions to IA after 30 days
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    # Delete non-current versions after 180 days
    noncurrent_version_expiration {
      noncurrent_days = 180
    }

    # Clean up incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}