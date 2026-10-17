# Deployer IAM Terraform Module

Creates the least privilege IAM managed policies a CI/CD pipeline needs to provision and
deprovision the parent module's resources. The policies are designed to be attached to the
role created by [terraform-aws-cicdrole](https://github.com/kbrockhoff/terraform-aws-cicdrole),
which already grants Terraform S3 backend access and the OIDC trust, so neither is included here.

Apply this module from a privileged platform/bootstrap configuration, not from the pipeline itself.

## Usage

```hcl
module "cicd_role" {
  source = "github.com/kbrockhoff/terraform-aws-cicdrole"

  name_prefix   = "prod-usw2"
  cicd_provider = "github-actions"
  git_repos     = ["my-infra-repo"]
  # ...
}

module "deployer" {
  source = "github.com/kbrockhoff/terraform-aws-s3backend//modules/deployer"

  name_prefix   = "prod-usw2" # same prefix the pipeline uses for the parent module
  iam_role_name = module.cicd_role.role_name
  partition     = data.aws_partition.current.partition
  region        = data.aws_region.current.region
  account_id    = data.aws_caller_identity.current.account_id
}
```

Leave `iam_role_name` empty to only create the policies and attach `policy_arns` elsewhere.

## Notes

The parent module is the Terraform state backend, so the state bucket
(`<name_prefix>-tfstate-<account_id>`), the KMS key, the alarms and the SNS topic are its own
resources. The policy grants their management (create, configure, delete) but no state object
read/write or locking; terraform-aws-cicdrole's `s3_backend_config` grants those.

Set `backward_compatibility_enabled = true` when the parent module sets it, to also grant
management of the deprecated DynamoDB lock table (`<name_prefix>-tfstate-<account_id>-lock`).

KMS key IDs are AWS-generated, so key permissions are scoped to `key/*` in the account and
region; `kms:ScheduleKeyDeletion` is further limited to keys tagged `Name = <name_prefix>-cmk`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.69.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID where the parent module is deployed | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Organization unique prefix to use for resource names. Must match the name\_prefix used when deploying the parent module. e.g. 'prod-usw2'. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the parent module is deployed | `string` | n/a | yes |
| <a name="input_backward_compatibility_enabled"></a> [backward\_compatibility\_enabled](#input\_backward\_compatibility\_enabled) | Must match the parent module's backward\_compatibility\_enabled. Set to true to also grant management of the deprecated DynamoDB lock table. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of an existing IAM role to attach the policies to, typically the role\_name output of terraform-aws-cicdrole. Leave empty to only create the policies. | `string` | `""` | no |
| <a name="input_partition"></a> [partition](#input\_partition) | AWS partition | `string` | `"aws"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags/labels to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_policy_arns"></a> [policy\_arns](#output\_policy\_arns) | Map of deployer IAM policy ARNs keyed by policy purpose |
| <a name="output_policy_names"></a> [policy\_names](#output\_policy\_names) | Map of deployer IAM policy names keyed by policy purpose |
<!-- END_TF_DOCS -->    