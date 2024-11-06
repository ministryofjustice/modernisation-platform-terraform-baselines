package main

import (
	"fmt"
	"regexp"
	"strings"
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

// Cloudtrail Module Unit Testing
func TestTerraformCloudtrail(t *testing.T) {
	t.Parallel()

	terraformDir := "./cloudtrail-test"
	uniqueId := random.UniqueId()

	// Unique names for Support resources
	CloudtrailName := fmt.Sprintf("cloudtrail-test%s", uniqueId)
	BucketName := fmt.Sprintf("cloudtrail-test-%s", strings.ToLower(uniqueId))
	CloudtrailPolicyName := fmt.Sprintf("AWSCloudTrail-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"cloudtrail_name":        CloudtrailName,
			"cloudtrail_bucket":      BucketName,
			"cloudtrail_policy_name": CloudtrailPolicyName,
		},
	}
	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform plan"
	// terraform.InitAndPlan(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Test backup module
	CloudwatchLogGroupARN := terraform.Output(t, terraformOptions, "cloudwatch_log_group_arn")
	CloudWatchLogStreamARN := terraform.Output(t, terraformOptions, "cloudwatch_log_stream_arn")
	SNSTopicARN := terraform.Output(t, terraformOptions, "sns_topic_arn")
	SNSTopicPolicyARN := terraform.Output(t, terraformOptions, "sns_topic_policy_arn")
	CloudtrailRoleARN := terraform.Output(t, terraformOptions, "cloudtrail_role_arn")
	CloudtrailPolicyARN := terraform.Output(t, terraformOptions, "cloudtrail_policy_arn")
	S3BucketARN := terraform.Output(t, terraformOptions, "s3_bucket_arn")
	S3PolicyAttachment := terraform.Output(t, terraformOptions, "s3_policy_attachment")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:logs:eu-west-2:[0-9]{12}:log-group:cloudtrail-test`+uniqueId), CloudwatchLogGroupARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:logs:eu-west-2:[0-9]{12}:log-group:cloudtrail-test`+uniqueId), CloudWatchLogStreamARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:[0-9]{12}:cloudtrail-test`+uniqueId), SNSTopicARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:[0-9]{12}:cloudtrail-test`+uniqueId), SNSTopicPolicyARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:iam::[0-9]{12}:role/cloudtrail-test`+uniqueId), CloudtrailRoleARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:iam::[0-9]{12}:policy/AWSCloudTrail-`+uniqueId), CloudtrailPolicyARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:s3:::cloudtrail-test*`), S3BucketARN)
	assert.Regexp(t, regexp.MustCompile(`cloudtrail-test*`), S3PolicyAttachment)
}

// SecurityHub Alarms Unit Testing
func TestTerraformSecurityHubAlarms(t *testing.T) {
	t.Parallel()

	terraformDir := "./securityhub-alarms-test"
	uniqueId := random.UniqueId()

	// Define unique names for SecurityHub Alarms resources
	SecurityhubAlarmsKmsName := fmt.Sprintf("alias/securityhub-alarms_key-%s", uniqueId)
	SecurityhubAlarmsMultiRegionKmsName := fmt.Sprintf("alias/securityhub-alarms-key-multi-region-%s", uniqueId)
	SecurityhubAlarmsSNSTopicName := fmt.Sprintf("securityhub-alarms-%s", uniqueId)
	UnauthorisedApiCallsFilterName := fmt.Sprintf("unauthorised-api-calls-%s", uniqueId)
	UnauthorisedApiCallsAlarmName := fmt.Sprintf("unauthorised-api-calls-%s", uniqueId)
	SignInWithoutMfaAlarmName := fmt.Sprintf("sign-in-without-mfa-%s", uniqueId)
	SignInWithoutMfaMetricFilterName := fmt.Sprintf("sign-in-without-mfa-%s", uniqueId)
	RootAccountUsageAlarmName := fmt.Sprintf("root-account-usage-%s", uniqueId)
	RootAccountUsageMetricFilterName := fmt.Sprintf("root-account-usage-%s", uniqueId)
	IamPolicyChangesAlarmName := fmt.Sprintf("iam-policy-changes-%s", uniqueId)
	IamPolicyChangesMetricFilterName := fmt.Sprintf("iam-policy-changes-%s", uniqueId)
	CloudtrailConfigurationChangesAlarmName := fmt.Sprintf("cloudtrail-configuration-changes-%s", uniqueId)
	CloudtrailConfigurationChangesMetricFilterName := fmt.Sprintf("cloudtrail-configuration-changes-%s", uniqueId)
	SignInFailuresAlarmName := fmt.Sprintf("sign-in-failures-%s", uniqueId)
	SignInFailuresMetricFilterName := fmt.Sprintf("sign-in-failures-%s", uniqueId)
	CmkRemovalAlarmName := fmt.Sprintf("cmk-removal-%s", uniqueId)
	CmkRemovalMetricFilterName := fmt.Sprintf("cmk-removal-%s", uniqueId)
	S3BucketPolicyChangesAlarmName := fmt.Sprintf("s3-bucket-policy-changes-%s", uniqueId)
	S3BucketPolicyChangesMetricFilterName := fmt.Sprintf("s3-bucket-policy-changes-%s", uniqueId)
	ConfigConfigurationChangesAlarmName := fmt.Sprintf("config-configuration-changes-%s", uniqueId)
	ConfigConfigurationChangesMetricFilterName := fmt.Sprintf("config-configuration-changes-%s", uniqueId)
	SecurityGroupChangesAlarmName := fmt.Sprintf("security-group-changes-%s", uniqueId)
	SecurityGroupChangesFilterName := fmt.Sprintf("security-group-changes-%s", uniqueId)
	NaclChangesAlarmName := fmt.Sprintf("nacl-changes-%s", uniqueId)
	NaclChangesMetricFilterName := fmt.Sprintf("nacl-changes-%s", uniqueId)
	NetworkGatewayChangesAlarmName := fmt.Sprintf("network-gateway-changes-%s", uniqueId)
	NetworkGatewayChangesMetricFilterName := fmt.Sprintf("network-gateway-changes-%s", uniqueId)
	RouteTableChangesAlarmName := fmt.Sprintf("route-table-changes-%s", uniqueId)
	RouteTableChangesMetricFilterName := fmt.Sprintf("route-table-changes-%s", uniqueId)
	VpcChangesAlarmName := fmt.Sprintf("vpc-changes-%s", uniqueId)
	VpcChangesMetricFilterName := fmt.Sprintf("vpc-changes-%s", uniqueId)
	PrivatelinkNewFlowCountAllAlarmName := fmt.Sprintf("PrivateLink-NewFlowCount-AllEndpoints-%s", uniqueId)
	PrivatelinkActiveFlowCountAllAlarmName := fmt.Sprintf("PrivateLink-ActiveFlowCount-AllEndpoints-%s", uniqueId)
	PrivatelinkServiceNewConnectionCountAllAlarmName := fmt.Sprintf("PrivateLink-Service-NewConnectionCount-AllServices-%s", uniqueId)
	PrivatelinkServiceActiveConnectionCountAllAlarmName := fmt.Sprintf("PrivateLink-Service-ActiveConnectionCount-AllServices-%s", uniqueId)
	AdminRoleUsageAlarmName := fmt.Sprintf("admin-role-usage-%s", uniqueId)
	AdminRoleUsageMetricFilterName := fmt.Sprintf("admin-role-usage-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			// Pass in unique names as terraform command line options
			"securityhub_alarms_kms_name":                                SecurityhubAlarmsKmsName,
			"securityhub_alarms_multi_region_kms_name":                   SecurityhubAlarmsMultiRegionKmsName,
			"securityhub_alarms_sns_topic_name":                          SecurityhubAlarmsSNSTopicName,
			"unauthorised_api_calls_log_metric_filter_name":              UnauthorisedApiCallsFilterName,
			"unauthorised_api_calls_alarm_name":                          UnauthorisedApiCallsAlarmName,
			"sign_in_without_mfa_alarm_name":                             SignInWithoutMfaAlarmName,
			"sign_in_without_mfa_metric_filter_name":                     SignInWithoutMfaMetricFilterName,
			"root_account_usage_alarm_name":                              RootAccountUsageAlarmName,
			"root_account_usage_metric_filter_name":                      RootAccountUsageMetricFilterName,
			"iam_policy_changes_alarm_name":                              IamPolicyChangesAlarmName,
			"iam_policy_changes_metric_filter_name":                      IamPolicyChangesMetricFilterName,
			"cloudtrail_configuration_changes_alarm_name":                CloudtrailConfigurationChangesAlarmName,
			"cloudtrail_configuration_changes_metric_filter_name":        CloudtrailConfigurationChangesMetricFilterName,
			"sign_in_failures_alarm_name":                                SignInFailuresAlarmName,
			"sign_in_failures_metric_filter_name":                        SignInFailuresMetricFilterName,
			"cmk_removal_alarm_name":                                     CmkRemovalAlarmName,
			"cmk_removal_metric_filter_name":                             CmkRemovalMetricFilterName,
			"s3_bucket_policy_changes_alarm_name":                        S3BucketPolicyChangesAlarmName,
			"s3_bucket_policy_changes_metric_filter_name":                S3BucketPolicyChangesMetricFilterName,
			"config_configuration_changes_alarm_name":                    ConfigConfigurationChangesAlarmName,
			"config_configuration_changes_metric_filter_name":            ConfigConfigurationChangesMetricFilterName,
			"security_group_changes_alarm_name":                          SecurityGroupChangesAlarmName,
			"security_group_changes_metric_filter_name":                  SecurityGroupChangesFilterName,
			"nacl_changes_alarm_name":                                    NaclChangesAlarmName,
			"nacl_changes_metric_filter_name":                            NaclChangesMetricFilterName,
			"network_gateway_changes_alarm_name":                         NetworkGatewayChangesAlarmName,
			"network_gateway_changes_metric_filter_name":                 NetworkGatewayChangesMetricFilterName,
			"route_table_changes_alarm_name":                             RouteTableChangesAlarmName,
			"route_table_changes_metric_filter_name":                     RouteTableChangesMetricFilterName,
			"vpc_changes_alarm_name":                                     VpcChangesAlarmName,
			"vpc_changes_metric_filter_name":                             VpcChangesMetricFilterName,
			"privatelink_new_flow_count_all_alarm_name":                  PrivatelinkNewFlowCountAllAlarmName,
			"privatelink_active_flow_count_all_alarm_name":               PrivatelinkActiveFlowCountAllAlarmName,
			"privatelink_service_new_connection_count_all_alarm_name":    PrivatelinkServiceNewConnectionCountAllAlarmName,
			"privatelink_service_active_connection_count_all_alarm_name": PrivatelinkServiceActiveConnectionCountAllAlarmName,
			"admin_role_usage_alarm_name":                                AdminRoleUsageAlarmName,
			"admin_role_usage_metric_filter_name":                        AdminRoleUsageMetricFilterName,
		},
	}
	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform plan"
	// terraform.InitAndPlan(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Test securityhub-alarms module

	// Define Outputs
	SnsTopicArn := terraform.Output(t, terraformOptions, "securityhub_alarms_sns_topic_arn")
	SecurityhubAlarmsKmsKeyArn := terraform.Output(t, terraformOptions, "securityhub_alarms_kms_key_arn")
	SecurityhubAlarmsKmsAliasArn := terraform.Output(t, terraformOptions, "securityhub_alarms_kms_alias_arn")
	SecurityhubAlarmsMultiRegionKmsKeyArn := terraform.Output(t, terraformOptions, "securityhub_alarms_multi_region_kms_key_arn")
	SecurityhubAlarmsMultiRegionKmsAliasArn := terraform.Output(t, terraformOptions, "securityhub_alarms_multi_region_kms_alias_arn")
	UnauthorisedApiCallsMetricFilterId := terraform.Output(t, terraformOptions, "unauthorised_api_calls_metric_filter_id")
	UnauthorisedApiCallsAlarmArn := terraform.Output(t, terraformOptions, "unauthorised_api_calls_alarm_arn")
	SignInWithoutMfaMetricFilterId := terraform.Output(t, terraformOptions, "sign_in_without_mfa_metric_filter_id")
	SignInWithoutMfaAlarmArn := terraform.Output(t, terraformOptions, "sign_in_without_mfa_alarm_arn")
	RootAccountUsageMetricFilterId := terraform.Output(t, terraformOptions, "root_account_usage_metric_filter_id")
	RootAccountUsageAlarmArn := terraform.Output(t, terraformOptions, "root_account_usage_alarm_arn")
	IamPolicyChangesMetricFilterId := terraform.Output(t, terraformOptions, "iam_policy_changes_metric_filter_id")
	IamPolicyChangesAlarmArn := terraform.Output(t, terraformOptions, "iam_policy_changes_alarm_arn")
	CloudtrailConfigurationChangesMetricFilterId := terraform.Output(t, terraformOptions, "cloudtrail_configuration_changes_metric_filter_id")
	CloudtrailConfigurationChangesAlarmArn := terraform.Output(t, terraformOptions, "cloudtrail_configuration_changes_alarm_arn")
	SignInFailuresMetricFilterId := terraform.Output(t, terraformOptions, "sign_in_failures_metric_filter_id")
	SignInFailuresAlarmArn := terraform.Output(t, terraformOptions, "sign_in_failures_alarm_arn")
	CmkRemovalMetricFilterId := terraform.Output(t, terraformOptions, "cmk_removal_metric_filter_id")
	CmkRemovalAlarmArn := terraform.Output(t, terraformOptions, "cmk_removal_alarm_arn")
	S3BucketPolicyChangesMetricFilterId := terraform.Output(t, terraformOptions, "s3_bucket_policy_changes_metric_filter_id")
	S3BucketPolicyChangesAlarmArn := terraform.Output(t, terraformOptions, "s3_bucket_policy_changes_alarm_arn")
	ConfigConfigurationChangesMetricFilterId := terraform.Output(t, terraformOptions, "config_configuration_changes_metric_filter_id")
	ConfigConfigurationChangesAlarmArn := terraform.Output(t, terraformOptions, "config_configuration_changes_alarm_arn")
	SecurityGroupChangesMetricFilterId := terraform.Output(t, terraformOptions, "security_group_changes_metric_filter_id")
	SecurityGroupChangesAlarmArn := terraform.Output(t, terraformOptions, "security_group_changes_alarm_arn")
	NaclChangesMetricFilterId := terraform.Output(t, terraformOptions, "nacl_changes_metric_filter_id")
	NaclChangesAlarmArn := terraform.Output(t, terraformOptions, "nacl_changes_alarm_arn")
	NetworkGatewayChangesMetricFilterId := terraform.Output(t, terraformOptions, "network_gateway_changes_metric_filter_id")
	NetworkGatewayChangesAlarmArn := terraform.Output(t, terraformOptions, "network_gateway_changes_alarm_arn")
	RouteTableChangesMetricFilterId := terraform.Output(t, terraformOptions, "route_table_changes_metric_filter_id")
	RouteTableChangesAlarmArn := terraform.Output(t, terraformOptions, "route_table_changes_alarm_arn")
	VpcChangesMetricFilterId := terraform.Output(t, terraformOptions, "vpc_changes_metric_filter_id")
	VpcChangesAlarmArn := terraform.Output(t, terraformOptions, "vpc_changes_alarm_arn")
	PrivatelinkNewFlowCountAllAlarmArn := terraform.Output(t, terraformOptions, "privatelink_new_flow_count_alarm_arn")
	PrivatelinkActiveFlowCountAllAlarmArn := terraform.Output(t, terraformOptions, "privatelink_active_flow_count_alarm_arn")
	PrivatelinkServiceNewConnectionCountAllAlarmArn := terraform.Output(t, terraformOptions, "privatelink_service_new_connection_count_alarm_arn")
	PrivatelinkServiceActiveConnectionCountAllAlarmArn := terraform.Output(t, terraformOptions, "privatelink_service_active_connection_count_alarm_arn")
	AdminRoleUsageAlarmArn := terraform.Output(t, terraformOptions, "admin_role_usage_alarm_arn")
	AdminRoleUsageMetricFilterId := terraform.Output(t, terraformOptions, "admin_role_usage_metric_filter_id")

	// Tests (comparing outputs to regex)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:[0-9]{12}:securityhub-alarms-`+uniqueId), SnsTopicArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:kms:eu-west-2:[0-9]{12}:key/*`), SecurityhubAlarmsKmsKeyArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:kms:eu-west-2:[0-9]{12}:alias/securityhub-alarms_key-`+uniqueId), SecurityhubAlarmsKmsAliasArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:kms:eu-west-2:[0-9]{12}:key/mrk-*`), SecurityhubAlarmsMultiRegionKmsKeyArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:kms:eu-west-2:[0-9]{12}:alias/securityhub-alarms-key-multi-region-`+uniqueId), SecurityhubAlarmsMultiRegionKmsAliasArn)
	assert.Regexp(t, regexp.MustCompile(UnauthorisedApiCallsFilterName), UnauthorisedApiCallsMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+UnauthorisedApiCallsAlarmName), UnauthorisedApiCallsAlarmArn)
	assert.Regexp(t, regexp.MustCompile(SignInWithoutMfaMetricFilterName), SignInWithoutMfaMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+SignInWithoutMfaAlarmName), SignInWithoutMfaAlarmArn)
	assert.Regexp(t, regexp.MustCompile(RootAccountUsageMetricFilterName), RootAccountUsageMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+RootAccountUsageAlarmName), RootAccountUsageAlarmArn)
	assert.Regexp(t, regexp.MustCompile(IamPolicyChangesMetricFilterName), IamPolicyChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+IamPolicyChangesAlarmName), IamPolicyChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(CloudtrailConfigurationChangesMetricFilterName), CloudtrailConfigurationChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+CloudtrailConfigurationChangesAlarmName), CloudtrailConfigurationChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(SignInFailuresMetricFilterName), SignInFailuresMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+SignInFailuresAlarmName), SignInFailuresAlarmArn)
	assert.Regexp(t, regexp.MustCompile(CmkRemovalMetricFilterName), CmkRemovalMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+CmkRemovalAlarmName), CmkRemovalAlarmArn)
	assert.Regexp(t, regexp.MustCompile(S3BucketPolicyChangesMetricFilterName), S3BucketPolicyChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+S3BucketPolicyChangesAlarmName), S3BucketPolicyChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(ConfigConfigurationChangesMetricFilterName), ConfigConfigurationChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+ConfigConfigurationChangesAlarmName), ConfigConfigurationChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(SecurityGroupChangesFilterName), SecurityGroupChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+SecurityGroupChangesAlarmName), SecurityGroupChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(NaclChangesMetricFilterName), NaclChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+NaclChangesAlarmName), NaclChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(NetworkGatewayChangesMetricFilterName), NetworkGatewayChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+NetworkGatewayChangesAlarmName), NetworkGatewayChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(RouteTableChangesMetricFilterName), RouteTableChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+RouteTableChangesAlarmName), RouteTableChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(VpcChangesMetricFilterName), VpcChangesMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+VpcChangesAlarmName), VpcChangesAlarmArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+PrivatelinkNewFlowCountAllAlarmName), PrivatelinkNewFlowCountAllAlarmArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+PrivatelinkActiveFlowCountAllAlarmName), PrivatelinkActiveFlowCountAllAlarmArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+PrivatelinkServiceNewConnectionCountAllAlarmName), PrivatelinkServiceNewConnectionCountAllAlarmArn)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+PrivatelinkServiceActiveConnectionCountAllAlarmName), PrivatelinkServiceActiveConnectionCountAllAlarmArn)
	assert.Regexp(t, regexp.MustCompile(AdminRoleUsageMetricFilterName), AdminRoleUsageMetricFilterId)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:cloudwatch:eu-west-2:[0-9]{12}:alarm:`+AdminRoleUsageAlarmName), AdminRoleUsageAlarmArn)
}

// SecurityHub Module Unit Testing
func TestTerraformSecurityHub(t *testing.T) {
	t.Parallel()

	terraformDir := "./securityhub-test"
	uniqueId := random.UniqueId()

	// Unique names for SecurityHub resources
	SecHubEventbridgeRuleName := fmt.Sprintf("sechub_high_and_critical_findings-%s", uniqueId)
	SecHubSNSTopicName := fmt.Sprintf("sechub_findings_sns_topic-%s", uniqueId)
	SecHubSNSTopicKMSKey := fmt.Sprintf("alias/sns-kms-key-%s", uniqueId)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Targets: []string{ // Targeting specific resources as not all are able to be duplicated in the same account
			"module.securityhub-test.aws_cloudwatch_event_rule.sechub_high_and_critical_findings",
			"module.securityhub-test.aws_cloudwatch_event_target.sechub_findings_sns_topic",
			"module.securityhub-test.aws_sns_topic.sechub_findings_sns_topic",
			"module.securityhub-test.aws_sns_topic_policy.sechub_findings_sns_topic",
			"module.securityhub-test.aws_iam_policy_document.sechub_findings_sns_topic_policy",
			"module.securityhub-test.aws_kms_key.sns_kms_key",
			"module.securityhub-test.aws_kms_alias.sns_kms_alias",
			"module.securityhub-test.aws_iam_policy_document.sns_kms",
		},
		Vars: map[string]interface{}{
			"sechub_eventbridge_rule_name": SecHubEventbridgeRuleName,
			"sechub_sns_topic_name":        SecHubSNSTopicName,
			"sechub_sns_kms_key_name":      SecHubSNSTopicKMSKey,
			"enable_securityhub_alerts":	true,
		},
	}
	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// SecurityHub module tests
	SecHubEventbridgeRuleARN := terraform.Output(t, terraformOptions, "sechub_eventbridge_rule_arn")
	SecHubSNSTopicARN := terraform.Output(t, terraformOptions, "sechub_sns_topic_arn")
	SecHubSNSTopicKMSKeyARN := terraform.Output(t, terraformOptions, "sechub_sns_kms_key_arn")

	assert.Regexp(t, regexp.MustCompile(`^arn:aws:events:eu-west-2:[0-9]{12}:rule/sechub_high_and_critical_findings-`+uniqueId), SecHubEventbridgeRuleARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:sns:eu-west-2:[0-9]{12}:sechub_findings_sns_topic-`+uniqueId), SecHubSNSTopicARN)
	assert.Regexp(t, regexp.MustCompile(`^arn:aws:kms:eu-west-2:[0-9]{12}:key/*`), SecHubSNSTopicKMSKeyARN)
}