package test

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// costComponents are the cost_breakdown keys the cost-estimation module promises
var costComponents = []string{
	"kms_keys",
	"s3_storage",
	"s3_put_requests",
	"s3_get_requests",
	"dynamodb_read_requests",
	"dynamodb_write_requests",
	"dynamodb_storage",
	"cloudwatch_alarms",
	"sns_requests",
}

// getCostEstimationOptions returns plan options for an isolated copy of the cost-estimation fixture
func getCostEstimationOptions(t *testing.T, vars map[string]interface{}) *terraform.Options {
	t.Helper()
	dir := copyExampleToTemp(t, "test/fixtures/cost-estimation")
	return &terraform.Options{
		TerraformDir: dir,
		Vars:         vars,
		PlanFilePath: filepath.Join(dir, "tfplan"),
		NoColor:      true,
	}
}

// plannedCostOutputs returns the planned monthly_cost_estimate and cost_breakdown outputs. The module
// only reads data sources, so both are known at plan time.
func plannedCostOutputs(t *testing.T, plan *terraform.PlanStruct) (float64, map[string]float64) {
	t.Helper()
	outputs := plan.RawPlan.PlannedValues.Outputs

	estimate, ok := outputs["monthly_cost_estimate"].Value.(float64)
	require.True(t, ok, "monthly_cost_estimate should be a number known at plan time")

	rawBreakdown, ok := outputs["cost_breakdown"].Value.(map[string]interface{})
	require.True(t, ok, "cost_breakdown should be a map known at plan time")

	breakdown := map[string]float64{}
	for k, v := range rawBreakdown {
		cost, ok := v.(float64)
		require.True(t, ok, "cost_breakdown[%s] should be a number", k)
		breakdown[k] = cost
	}
	return estimate, breakdown
}

func TestCostEstimationPricesEveryComponent(t *testing.T) {
	t.Parallel()

	terraformOptions := getCostEstimationOptions(t, map[string]interface{}{
		"region":                               "us-west-2",
		"kms_key_count":                        1,
		"s3_storage_gb":                        10,
		"s3_put_requests_monthly":              1000000,
		"s3_get_requests_monthly":              1000000,
		"dynamodb_read_request_units_monthly":  1000000,
		"dynamodb_write_request_units_monthly": 1000000,
		"dynamodb_storage_gb":                  1,
		"cloudwatch_alarm_count":               5,
	})
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	estimate, breakdown := plannedCostOutputs(t, plan)

	sum := 0.0
	for _, component := range costComponents {
		cost, ok := breakdown[component]
		if assert.True(t, ok, "cost_breakdown should include %s", component) {
			assert.Greater(t, cost, 0.0, "%s should have a cost for non-zero usage", component)
			sum += cost
		}
	}
	assert.Len(t, breakdown, len(costComponents), "cost_breakdown should only include known components")
	assert.InDelta(t, sum, estimate, 0.000001, "monthly_cost_estimate should equal the sum of cost_breakdown")

	// One million S3 PUTs cost about $5 in every region; guards against per-1,000 request unit errors
	assert.InDelta(t, 5.0, breakdown["s3_put_requests"], 3.0,
		"1M S3 PUT requests should cost roughly $5, got %v", breakdown["s3_put_requests"])
}

func TestCostEstimationZeroUsageCostsNothing(t *testing.T) {
	t.Parallel()

	// All quantities default to zero in the fixture
	terraformOptions := getCostEstimationOptions(t, map[string]interface{}{})
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	estimate, breakdown := plannedCostOutputs(t, plan)

	assert.Equal(t, 0.0, estimate, "zero usage should estimate $0")
	for _, component := range costComponents {
		assert.Equal(t, 0.0, breakdown[component], "%s should cost $0 with zero usage", component)
	}
}

func TestCostEstimationDisabledReturnsEmpty(t *testing.T) {
	t.Parallel()

	terraformOptions := getCostEstimationOptions(t, map[string]interface{}{
		"enabled":       false,
		"kms_key_count": 1,
	})
	defer terraform.Destroy(t, terraformOptions)

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	estimate, breakdown := plannedCostOutputs(t, plan)

	assert.Equal(t, 0.0, estimate, "enabled=false should estimate $0")
	assert.Empty(t, breakdown, "enabled=false should return an empty cost_breakdown")
}

func TestCostEstimationRejectsNegativeQuantities(t *testing.T) {
	t.Parallel()

	terraformOptions := getCostEstimationOptions(t, map[string]interface{}{
		"cloudwatch_alarm_count": -1,
	})

	_, err := terraform.InitAndPlanE(t, terraformOptions)

	require.Error(t, err, "plan should fail for a negative quantity")
	assert.Contains(t, err.Error(), "must be zero or positive")
}
