# Changelog

## [1.0.0](https://github.com/kbrockhoff/terraform-aws-s3backend/compare/v0.1.0...v1.0.0) (2026-10-24)


### ⚠ BREAKING CHANGES

* **cost-estimation:** modules/pricing is now modules/cost-estimation with quantity inputs (create_kms_key -> kms_key_count, cloudwatch_alarms_count -> cloudwatch_alarm_count, dynamo_* -> dynamodb_*). cost_breakdown keys dynamo_read_requests, dynamo_write_requests and dynamo_storage are renamed to dynamodb_*, and sns_requests is added.
* **deployer:** modules/bootstrap is removed, along with its role, github_org, github_repo, environment and state backend inputs and its role and policy outputs. Cut over in this order: apply terraform-aws-cicdrole and modules/deployer with iam_role_name = module.<cicdrole>.role_name; point the pipeline at the <name_prefix>-cicd-deployer role and confirm a plan; then remove the old bootstrap module, which destroys the <name_prefix>-github-actions role.
* the DynamoDB lock table and its alarms are destroyed on upgrade unless backward_compatibility_enabled = true. The bootstrap submodule's s3_backend_lock_table input was removed.

### Features

* replace DynamoDB locking with S3 native lockfile ([cdd8546](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/cdd8546003249de5528d16410453d7df08d347e5))


### Bug Fixes

* **bootstrap:** grant DynamoDB permissions when lock table is configured ([4a6054a](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/4a6054ac1d1ec336d3c8d65d4a241efae33be338))
* **deployer:** scope KMS permissions to the module-owned key ([e8b8a66](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/e8b8a66d4dd572f5d24e0fd3d839ee19c823ebdb))


### Code Refactoring

* **cost-estimation:** replace pricing submodule with cost-estimation ([e1c2eda](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/e1c2eda167771ebf06f2ffdea94991574d13a87d))
* **deployer:** replace bootstrap submodule with deployer policies ([d71ef47](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/d71ef47dba371f9bb52fdca773308487bbfcc420))

## 0.1.0 (2025-08-09)


### Features

* add comprehensive cost estimation for S3, DynamoDB, and CloudWatch ([fc10de8](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/fc10de88f17df2292a09d27efd62c9e5675d5679))
* add comprehensive Makefile with AI-optimized development workflow ([877f080](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/877f080341157f636c64005124a4788d38e422fd))
* add comprehensive resource management policies to bootstrap module ([3ce65f4](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/3ce65f4e8601fa081ce29b87cbc60f13a4492d2e))
* add S3 bucket and DynamoDB table for Terraform backend ([51dae0f](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/51dae0f4b336fdfd890f81b2e5d8bf81492a47ba))
* add S3 bucket lifecycle policy for cost optimization ([e3872ec](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/e3872ece2a333365982564dd389d0f7006b0363d))
* **monitoring:** add create_alarm_sns_topic variable for explicit SNS topic control ([1ea5a7e](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/1ea5a7e43be2d70811d15c4592a5af098a6e7bbd))


### Bug Fixes

* add more error proofing ([577bf9b](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/577bf9ba38082a9b44f18df301b47aab0a2bd112))
* **github:** correct module references in templates and documentation ([4f8c562](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/4f8c562946894db3f222de8f2f2d03db17bfa850))
* **test:** add missing regexp import to defaults_test.go ([837b148](https://github.com/kbrockhoff/terraform-aws-s3backend/commit/837b148751f23b6bbe67aae16b76c6d620ed2e16))

## Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
