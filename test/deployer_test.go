package test

import (
	"encoding/json"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	deployerTestAccountID = "123456789012"
	deployerTestRegion    = "us-west-2"
	deployerPolicyAddress = `module.deployer.aws_iam_policy.this["main"]`
	deployerAttachAddress = `module.deployer.aws_iam_role_policy_attachment.this["main"]`
)

// policyStatement is an IAM policy statement; Action and Resource may be a string or a list
type policyStatement struct {
	Sid      string          `json:"Sid"`
	Action   json.RawMessage `json:"Action"`
	Resource json.RawMessage `json:"Resource"`
}

// getDeployerOptions returns plan options for an isolated copy of the deployer fixture
func getDeployerOptions(t *testing.T, vars map[string]interface{}) *terraform.Options {
	t.Helper()
	dir := copyExampleToTemp(t, "test/fixtures/deployer")
	return &terraform.Options{
		TerraformDir: dir,
		Vars:         vars,
		PlanFilePath: filepath.Join(dir, "tfplan"),
		NoColor:      true,
	}
}

// plannedDeployerPolicy returns the statements of the planned main deployer policy, keyed by Sid
func plannedDeployerPolicy(t *testing.T, plan *terraform.PlanStruct) map[string]policyStatement {
	t.Helper()
	resource, ok := plan.ResourcePlannedValuesMap[deployerPolicyAddress]
	require.True(t, ok, "expected %s in plan", deployerPolicyAddress)

	policyJSON, ok := resource.AttributeValues["policy"].(string)
	require.True(t, ok, "policy should be known at plan time")

	var doc struct {
		Statement []policyStatement `json:"Statement"`
	}
	require.NoError(t, json.Unmarshal([]byte(policyJSON), &doc))

	statements := map[string]policyStatement{}
	for _, s := range doc.Statement {
		statements[s.Sid] = s
	}
	return statements
}

// stringList decodes an IAM policy element that may be a single string or a list of strings
func stringList(t *testing.T, raw json.RawMessage) []string {
	t.Helper()
	var list []string
	if err := json.Unmarshal(raw, &list); err == nil {
		return list
	}
	var single string
	require.NoError(t, json.Unmarshal(raw, &single))
	return []string{single}
}

func TestDeployerCreatesPolicyScopedToStateBucket(t *testing.T) {
	t.Parallel()
	namePrefix := generateTestNamePrefix("dep")

	terraformOptions := getDeployerOptions(t, map[string]interface{}{
		"name_prefix": namePrefix,
	})
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	policy, ok := plan.ResourcePlannedValuesMap[deployerPolicyAddress]
	require.True(t, ok, "expected %s in plan", deployerPolicyAddress)
	assert.Equal(t, namePrefix+"-s3backend-deployer-main", policy.AttributeValues["name"])

	// Policies are only created, not attached, when iam_role_name is empty
	assert.NotContains(t, plan.ResourcePlannedValuesMap, deployerAttachAddress,
		"policy should not be attached without iam_role_name")

	statements := plannedDeployerPolicy(t, plan)

	bucket, ok := statements["S3BucketManagement"]
	require.True(t, ok, "expected S3BucketManagement statement")
	assert.Equal(t, []string{"arn:aws:s3:::" + namePrefix + "-tfstate-" + deployerTestAccountID},
		stringList(t, bucket.Resource), "S3 permissions should be scoped to the state bucket only")

	assert.NotContains(t, statements, "DynamoDBTableManagement",
		"lock table permissions should require backward_compatibility_enabled")

	// The deployer manages the backend but never reads or writes state; cicdrole grants that
	for sid, s := range statements {
		for _, action := range stringList(t, s.Action) {
			assert.False(t, strings.HasSuffix(action, "Object") || strings.HasSuffix(action, "Item"),
				"statement %s grants state data action %s", sid, action)
		}
	}
}

func TestDeployerAttachesPolicyToRole(t *testing.T) {
	t.Parallel()
	namePrefix := generateTestNamePrefix("dep")
	roleName := namePrefix + "-cicd-deployer"

	terraformOptions := getDeployerOptions(t, map[string]interface{}{
		"name_prefix":   namePrefix,
		"iam_role_name": roleName,
	})
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	attachment, ok := plan.ResourcePlannedValuesMap[deployerAttachAddress]
	require.True(t, ok, "expected %s when iam_role_name is set", deployerAttachAddress)
	assert.Equal(t, roleName, attachment.AttributeValues["role"])
}

func TestDeployerBackwardCompatibilityGrantsLockTable(t *testing.T) {
	t.Parallel()
	namePrefix := generateTestNamePrefix("dep")

	terraformOptions := getDeployerOptions(t, map[string]interface{}{
		"name_prefix":                    namePrefix,
		"backward_compatibility_enabled": true,
	})
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	statements := plannedDeployerPolicy(t, plan)

	table, ok := statements["DynamoDBTableManagement"]
	require.True(t, ok, "expected DynamoDBTableManagement statement when backward_compatibility_enabled=true")
	assert.Equal(t,
		[]string{"arn:aws:dynamodb:" + deployerTestRegion + ":" + deployerTestAccountID + ":table/" +
			namePrefix + "-tfstate-" + deployerTestAccountID + "-lock"},
		stringList(t, table.Resource), "DynamoDB permissions should be scoped to the lock table only")
}

func TestDeployerDisabledCreatesNothing(t *testing.T) {
	t.Parallel()

	terraformOptions := getDeployerOptions(t, map[string]interface{}{
		"enabled":       false,
		"name_prefix":   generateTestNamePrefix("dep"),
		"iam_role_name": "unused-role",
	})
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	assert.Empty(t, plan.ResourcePlannedValuesMap, "enabled=false should plan no resources")
}

func TestDeployerRejectsInvalidAccountID(t *testing.T) {
	t.Parallel()

	terraformOptions := getDeployerOptions(t, map[string]interface{}{
		"name_prefix": generateTestNamePrefix("dep"),
		"account_id":  "12345",
	})

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	require.Error(t, err, "plan should fail for a non 12 digit account_id")
	assert.Contains(t, err.Error(), "12 digit AWS account ID")
}
