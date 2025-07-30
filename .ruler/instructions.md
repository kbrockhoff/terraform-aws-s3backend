# AWS Terraform S3 Backend Terraform Module Guide for AI Agents

Provisions the resources required to create an S3 backend for Terraform.

## Components

### S3 Bucket
- No public access
- Versioning enabled
- CMK with key rotation and bucket key enabled
- Bucket policy requires secure transport
- Name format "${local.name_prefix}-tfstate-${local.account_id}

### DynamoDB Table
- CMK with key rotation enabled
- Minimal read/write capacity
- Name format "${local.name_prefix}-tfstate-${local.account_id}-lock
