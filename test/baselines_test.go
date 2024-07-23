package main

import (
	"fmt"
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Backup Module Unit Testing
func TestTerraformBackup(t *testing.T) {
	t.Parallel()

	terraformDir := "./backup-test"
	uniqueId := random.UniqueId()

	// Unique names for Backup resources
	BackupIamRoleName := fmt.Sprintf("AWSBackup-%s", uniqueId)
	BackupVaultName := fmt.Sprintf("everything-%s", uniqueId)
	ProdBackupVaultName := fmt.Sprintf("backup-daily-retain-30-days-%s", uniqueId)
	ProdBackupSelectionName := fmt.Sprintf("is-production-true-%s", uniqueId)
	NonProdBackupPlanName := fmt.Sprintf("backup-daily-cold-storage-monthly-retain-30-days-%s", uniqueId)
	NonProdBackupSelectionName := fmt.Sprintf("non-production-backup-%s", uniqueId)
	BackupSNSTopicName := fmt.Sprintf("backup_failure_topic-%s", uniqueId)
	BackupLockSNSTopicName := fmt.Sprintf("backup_vault_lock_sns_topic_name-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"aws_iam_role_backup_name":             BackupIamRoleName,
			"aws_backup_vault_name":                BackupVaultName,
			"production_backup_plan_name":          ProdBackupVaultName,
			"production_backup_selection_name":     ProdBackupSelectionName,
			"non_production_backup_plan_name":      NonProdBackupPlanName,
			"non_production_backup_selection_name": NonProdBackupSelectionName,
			"backup_aws_sns_topic_name":            BackupSNSTopicName,
			"backup_vault_lock_sns_topic_name":     BackupLockSNSTopicName,
		},
	}
	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform plan"
	// terraform.InitAndPlan(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Test backup module
	AwsBackupVaultArn := terraform.Output(t, terraformOptions, "aws_backup_vault_arn")
	AwsBackupPlanProd := terraform.Output(t, terraformOptions, "aws_backup_plan_production")
	AwsBackupPlanNonProd := terraform.Output(t, terraformOptions, "aws_backup_plan_non_production")
	AwsBackupSelectionProd := terraform.Output(t, terraformOptions, "aws_backup_selection_production")
	AwsBackupSelectionNonProd := terraform.Output(t, terraformOptions, "aws_backup_selection_non_production")
	AwsBackupSNSTopicArn := terraform.Output(t, terraformOptions, "backup_aws_sns_topic_arn")
	AwsNonProdBackupRetentionDays := terraform.Output(t, terraformOptions, "aws_backup_plan_non_production_rule")
	AwsVaultSNSTopicName := terraform.Output(t, terraformOptions, "backup_vault_lock_sns_topic_name")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:backup:eu-west-2:[0-9]{12}:backup-vault:everything-`+uniqueId), AwsBackupVaultArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:backup:eu-west-2:[0-9]{12}:backup-plan:*`), AwsBackupPlanProd)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:backup:eu-west-2:[0-9]{12}:backup-plan:*`), AwsBackupPlanNonProd)
	assert.Regexp(t, regexp.MustCompile(`^*`), AwsBackupSelectionProd)
	assert.Regexp(t, regexp.MustCompile(`^*`), AwsBackupSelectionNonProd)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:[0-9]{12}:backup_failure_topic-`+uniqueId), AwsBackupSNSTopicArn)
	assert.Regexp(t, regexp.MustCompile(`delete_after:40`), AwsNonProdBackupRetentionDays)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:[0-9]{12}:backup_vault_lock_sns_topic_name-`+uniqueId), AwsVaultSNSTopicName)

}

// Support Module Unit Testing
func TestTerraformSupport(t *testing.T) {
	t.Parallel()

	terraformDir := "./support-test"
	uniqueId := random.UniqueId()

	// Unique names for Support resources
	SupportIamRoleName := fmt.Sprintf("support-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"role_name": SupportIamRoleName,
		},
	}
	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform plan"
	// terraform.InitAndPlan(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Test backup module
	AwsSupportRoleARN := terraform.Output(t, terraformOptions, "aws_support_role_arn")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:iam::[0-9]{12}:role/support-`+uniqueId), AwsSupportRoleARN)

}
