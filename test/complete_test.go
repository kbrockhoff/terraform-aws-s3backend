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
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",

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
	
	// DynamoDB table
	assert.Contains(t, planOutput, "module.main.aws_dynamodb_table.tfstate_lock[0]")
	
	// SNS topic for alarms
	assert.Contains(t, planOutput, "module.main.aws_sns_topic.alarms[0]")
	
	// CloudWatch alarms
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.s3_5xx_errors[0]")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.s3_4xx_errors[0]")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.s3_bytes_downloaded[0]")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.dynamodb_read_throttling[0]")
	assert.Contains(t, planOutput, "module.main.aws_cloudwatch_metric_alarm.dynamodb_write_throttling[0]")
	
	// Verify proper resource count (should show 15 resources to add)
	assert.Contains(t, planOutput, "15 to add, 0 to change, 0 to destroy")

}

func TestEnabledFalse(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("comp")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",

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
