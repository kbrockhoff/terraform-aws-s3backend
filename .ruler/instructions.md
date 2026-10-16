# AWS Terraform S3 Backend Terraform Module Guide for AI Agents

Provisions the resources required to create an S3 backend for Terraform.

## Components

### S3 Bucket
- No public access
- Versioning enabled
- CMK with key rotation and bucket key enabled
- Bucket policy requires secure transport
- Name format "${local.name_prefix}-tfstate-${local.account_id}

### State Locking
- Native S3 lock files (`use_lockfile = true`); no DynamoDB table
- Lock files (`<key>.tflock`) are encrypted with the same CMK as state
- `backward_compatibility_enabled = true` also creates a DynamoDB lock table (CMK encrypted,
  on-demand billing, name format "${local.name_prefix}-tfstate-${local.account_id}-lock")
