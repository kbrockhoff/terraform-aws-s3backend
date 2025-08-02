package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const RandomIDLength = 10

func TestTerraformDefaultsExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("def")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/defaults",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name_prefix": expectedName,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate configuration without creating resources
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors and shows expected output changes
	assert.NotEmpty(t, planOutput)
	assert.Contains(t, planOutput, "Terraform will perform the following actions:")
	
	// Verify expected resources will be created
	// KMS resources
	assert.Contains(t, planOutput, "module.main.aws_kms_key.main[0]")
	assert.Contains(t, planOutput, "will be created")
	assert.Contains(t, planOutput, "module.main.aws_kms_alias.main[0]")
	
	// S3 bucket resources
	assert.Contains(t, planOutput, "module.main.aws_s3_bucket.tfstate[0]")
	assert.Contains(t, planOutput, "module.main.aws_s3_bucket_server_side_encryption_configuration.tfstate[0]")
	assert.Contains(t, planOutput, "module.main.aws_s3_bucket_versioning.tfstate[0]")
	assert.Contains(t, planOutput, "module.main.aws_s3_bucket_public_access_block.tfstate[0]")
	assert.Contains(t, planOutput, "module.main.aws_s3_bucket_policy.tfstate[0]")
	assert.Contains(t, planOutput, "module.main.aws_s3_bucket_lifecycle_configuration.tfstate[0]")
	
	// DynamoDB table
	assert.Contains(t, planOutput, "module.main.aws_dynamodb_table.tfstate_lock[0]")
	
	// Verify proper resource count (should show 9 resources to add)
	assert.Contains(t, planOutput, "9 to add, 0 to change, 0 to destroy")

}
