package test

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// TestMain sets up and tears down any shared test resources
func TestMain(m *testing.M) {
	// Run the tests
	m.Run()
}

// copyExampleToTemp copies the repo's Terraform sources to a per-test temp dir and returns the example
// (or test/fixtures) path within it, so tests sharing a configuration can run in parallel without racing
// on .terraform or local state. The modules are copied too because configurations reference them via
// relative sources.
func copyExampleToTemp(t *testing.T, examplePath string) string {
	t.Helper()
	srcRoot := ".."
	dstRoot := t.TempDir()

	err := filepath.WalkDir(srcRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		// Skip hidden dirs (.git, .terraform, vendored agent skills); only Terraform files are copied
		if d.IsDir() && path != srcRoot && strings.HasPrefix(d.Name(), ".") {
			return filepath.SkipDir
		}
		if d.IsDir() || !isTerraformSource(d.Name()) {
			return nil
		}
		rel, err := filepath.Rel(srcRoot, path)
		if err != nil {
			return err
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		dst := filepath.Join(dstRoot, rel)
		if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
			return err
		}
		return os.WriteFile(dst, data, 0o644)
	})
	if err != nil {
		t.Fatalf("copying Terraform sources to temp dir: %v", err)
	}
	return filepath.Join(dstRoot, examplePath)
}

// isTerraformSource reports whether a file is needed to init and plan, excluding local state
func isTerraformSource(name string) bool {
	return strings.HasSuffix(name, ".tf") || strings.HasSuffix(name, ".tfvars") || name == ".terraform.lock.hcl"
}

// Helper function to get default terraform options for testing
func getBaseTerraformOptions(terraformDir string) *terraform.Options {
	return &terraform.Options{
		TerraformDir: terraformDir,
		NoColor:      true,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed":                  "Intermittent AWS API error",
			"NoCredentialProviders: no valid providers in chain": "AWS credentials issue",
			"dial tcp: lookup":                                   "DNS resolution issue",
			"timeout while waiting for plugin to start":          "Plugin timeout",
			"connection reset by peer":                           "Network connectivity issue",
			"TooManyRequestsException":                           "AWS throttling",
			"ThrottlingException":                                "AWS throttling",
			"RequestLimitExceeded":                               "AWS throttling",
			"ServiceUnavailableException":                        "AWS service temporarily unavailable",
			"InternalServerError":                                "AWS internal error",
			"InvalidParameterException":                          "AWS parameter validation error",
			"ValidationException":                                "AWS validation error",
			"UnauthorizedOperation":                              "AWS authorization error",
			"InvalidUserID.NotFound":                             "AWS user/role not found",
			"AccessDenied":                                       "AWS access denied",
			"Throttling":                                         "AWS throttling",
			"RequestTimeout":                                     "AWS request timeout",
			"PendingVerification":                                "AWS account verification pending",
			"OptInRequired":                                      "AWS service opt-in required",
			"InsufficientInstanceCapacity":                       "AWS capacity issue",
			"InvalidAvailabilityZone":                            "AWS AZ issue",
			"InvalidSubnetID.NotFound":                           "AWS subnet not found",
			"InvalidVpcID.NotFound":                              "AWS VPC not found",
			"InvalidGroupId.NotFound":                            "AWS security group not found",
			"DryRunOperation":                                    "AWS dry run operation",
			"RequestExpired":                                     "AWS request expired",
			"SignatureDoesNotMatch":                              "AWS signature mismatch",
			"NetworkInterfaceInUse":                              "AWS network interface in use",
			"InvalidNetworkInterfaceID.NotFound":                 "AWS network interface not found",
			"InvalidInstanceID.NotFound":                         "AWS instance not found",
			"IncorrectInstanceState":                             "AWS instance state issue",
			"InvalidSnapshot.NotFound":                           "AWS snapshot not found",
			"InvalidVolume.NotFound":                             "AWS volume not found",
			"VolumeInUse":                                        "AWS volume in use",
			"IncorrectState":                                     "AWS resource state issue",
			"InvalidKeyPair.NotFound":                            "AWS key pair not found",
			"InvalidAMIID.NotFound":                              "AWS AMI not found",
			"InvalidAMIID.Malformed":                             "AWS AMI ID malformed",
			"InvalidLaunchTemplateName.NotFound":                 "AWS launch template not found",
			"InvalidAutoScalingGroupName":                        "AWS ASG name invalid",
			"ValidationError":                                    "AWS validation error",
			"AlreadyExistsException":                             "AWS resource already exists",
			"ResourceNotFoundException":                          "AWS resource not found",
			"ResourceInUseException":                             "AWS resource in use",
			"InvalidRequestException":                            "AWS invalid request",
			"MalformedPolicyDocumentException":                   "AWS policy document malformed",
			"EntityAlreadyExistsException":                       "AWS IAM entity already exists",
			"NoSuchEntityException":                              "AWS IAM entity not found",
			"DeleteConflictException":                            "AWS delete conflict",
			"LimitExceededException":                             "AWS limit exceeded",
			"PolicyVersionLimitExceededException":                "AWS policy version limit exceeded",
			"UnmodifiableEntityException":                        "AWS entity unmodifiable",
			"ServiceFailureException":                            "AWS service failure",
			"ConcurrentModificationException":                    "AWS concurrent modification",
			"InvalidInputException":                              "AWS invalid input",
			"KeyUsageNotPermittedException":                      "AWS KMS key usage not permitted",
			"KMSInvalidStateException":                           "AWS KMS invalid state",
			"NotFoundException":                                  "AWS KMS key not found",
			"UnsupportedOperationException":                      "AWS KMS unsupported operation",
			"DisabledException":                                  "AWS KMS key disabled",
			"InvalidAliasNameException":                          "AWS KMS alias name invalid",
		},
		MaxRetries: 3,
	}
}

// generateTestNamePrefix generates a unique test name prefix with consistent length
func generateTestNamePrefix(prefix string) string {
	randomId := strings.ToLower(random.UniqueId())
	if len(randomId) > RandomIDLength {
		randomId = randomId[:RandomIDLength]
	} else {
		// Pad with zeros if too short
		randomId = randomId + strings.Repeat("0", RandomIDLength-len(randomId))
	}
	return prefix + "-" + randomId
}
