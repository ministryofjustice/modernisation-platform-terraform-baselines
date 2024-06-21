package main

import (
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestSNSCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	snsSubscriptionArn := terraform.Output(t, terraformOptions, "sns_subscription_arn")
	snsTopicArn := terraform.Output(t, terraformOptions, "sns_topic_arn")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:\d{12}:test_alarms:.*`), snsSubscriptionArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:\d{12}:test_alarms`), snsTopicArn)

}
