package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCompleteExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("comp")

	terraformOptions := &terraform.Options{
		// Isolated copy of the example so parallel tests don't share .terraform or local state
		TerraformDir: copyExampleToTemp(t, "examples/complete"),

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name_prefix":      expectedName,
			"environment_type": "None",
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
	
	// State locking uses S3 lock files (use_lockfile), so no DynamoDB table should be planned
	assert.NotContains(t, planOutput, "aws_dynamodb_table", "DynamoDB lock table should not be created")
	
	// SNS topic for alarms
	assert.Contains(t, planOutput, "module.main.aws_sns_topic.alarms[0]")
	
	// CloudWatch alarms
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.s3_5xx_errors[0]")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.s3_4xx_errors[0]")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.s3_bytes_downloaded[0]")
	
	// Verify proper resource count (should show 12 resources to add)
	assert.Contains(t, planOutput, "12 to add, 0 to change, 0 to destroy")

}

func TestBackwardCompatibilityEnabledCreatesLockTable(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("bc")

	terraformOptions := &terraform.Options{
		// Isolated copy of the example so parallel tests don't share .terraform or local state
		TerraformDir: copyExampleToTemp(t, "examples/complete"),

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name_prefix":                    expectedName,
			"environment_type":               "None",
			"backward_compatibility_enabled": true,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate configuration without creating resources
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// DynamoDB lock table and its alarms are added for deprecated dynamodb_table backends
	assert.Contains(t, planOutput, "module.main.aws_dynamodb_table.tfstate_lock[0]",
		"DynamoDB lock table should be created when backward_compatibility_enabled=true")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.dynamodb_read_throttling[0]")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.dynamodb_write_throttling[0]")

	// Verify proper resource count (12 base resources + lock table + 2 alarms)
	assert.Contains(t, planOutput, "15 to add, 0 to change, 0 to destroy")

}

func TestEnabledFalse(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("comp")

	terraformOptions := &terraform.Options{
		// Isolated copy of the example so parallel tests don't share .terraform or local state
		TerraformDir: copyExampleToTemp(t, "examples/complete"),

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"enabled":          false,
			"name_prefix":      expectedName,
			"environment_type": "None",
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
	assert.Contains(t, planOutput, "No changes.")

}
