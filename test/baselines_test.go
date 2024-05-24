package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformBaselines(t *testing.T) {
	t.Parallel()

	terraformDir := "./unit-test"

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
	}

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform plan"
	terraform.InitAndPlan(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	// terraform.InitAndApply(t, terraformOptions)
}
