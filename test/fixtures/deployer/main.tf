# Test fixture: plans the deployer submodule in isolation. Region and account ID are
# inputs, so the policies are rendered for the given values rather than looked up.
provider "aws" {
  region = var.region
}

module "deployer" {
  source = "../../../modules/deployer"

  enabled                        = var.enabled
  name_prefix                    = var.name_prefix
  iam_role_name                  = var.iam_role_name
  region                         = var.region
  account_id                     = var.account_id
  backward_compatibility_enabled = var.backward_compatibility_enabled
}
