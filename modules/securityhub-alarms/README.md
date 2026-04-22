# SecurityHub Alarms

Terraform module for creating CloudWatch log metric filters and CloudWatch alarms used by Modernisation Platform baseline accounts. The module still covers the legacy CIS AWS Foundations Benchmark v1.2.0 log-based controls, and it also adds Modernisation Platform-specific detection for privileged role usage, Secrets Manager access, S3 object deletion, Network Firewall changes, and other high-value events.

## What This Module Creates

The module creates:

- KMS keys and aliases used to encrypt alarm SNS topics.
- A standard SNS topic for lower-priority alarms.
- A high-priority SNS topic for urgent alarms.
- CloudWatch log metric filters over the account CloudTrail log group.
- CloudWatch metric alarms driven either directly from one metric or from metric math.
- A PagerDuty integration module wired to the high-priority SNS topic.

## Usage

```hcl
module "securityhub-alarms" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/securityhub-alarms"
}
```

## Local Values

### Account and Environment Locals

| Local | Purpose |
| --- | --- |
| `mp_owned_workspaces` | Regex and literal workspace patterns treated as Modernisation Platform-owned accounts. |
| `is_mp_workspace` | True when the current Terraform workspace matches one of the MP-owned workspace patterns. |
| `account_name` | Workspace-derived account name with the final environment suffix removed. |
| `environment_definition` | Decoded JSON environment definition loaded from the modernisation-platform repository for non-default workspaces. |
| `member_unrestricted_account_prefixes` | Account name prefixes treated as member-unrestricted even if the JSON metadata is absent or incomplete. |
| `is_member_unrestricted` | True when the account is classified as `member-unrestricted` from metadata or by prefix rule. |
| `environment_name` | Final dash-separated segment of the workspace name, such as `development` or `production`. |
| `current_environment_access` | Access configuration for the current environment extracted from the environment definition JSON. |
| `is_sandbox_environment` | True when the current environment access definition includes sandbox-level access. |
| `is_suppressed_account` | True when the account is either member-unrestricted or sandbox, and therefore should suppress some alarm actions. |
| `is_mp_account` | True only for the default workspace. |
| `is_core_account` | True when the workspace name begins with `core-`. |
| `is_cp_account` | True when the workspace name begins with `cloud-platform-`. |

### Alarm Action Locals

| Local | Purpose |
| --- | --- |
| `low_priority_alarm_action` | Standard SNS action list for lower-priority alarms. |
| `mp_accounts_low_priority_alarm_action` | Lower-priority SNS action list enabled only for MP-owned workspaces. |
| `high_priority_excluding_suppressed_alarm_action` | High-priority SNS action list, disabled when the account is suppressed. |
| `low_priority_excluding_suppressed_alarm_action` | Low-priority SNS action list, disabled when the account is suppressed. |

### Filtering Local

| Local | Purpose |
| --- | --- |
| `automation_role_filter` | CloudWatch Logs filter expression fragment that excludes trusted automation roles. The exact expression varies for MP, core, Cloud Platform, and member accounts. |

### Event List and Scope Locals

These locals define the sets of events or identities used by the `for_each` metric filters and scoped alarms.

| Local | Purpose |
| --- | --- |
| `iam_policy_change_event_names` | IAM policy API actions that should generate alerts when performed outside trusted automation. |
| `cloudtrail_configuration_change_event_names` | CloudTrail trail management API actions that indicate audit logging changes. |
| `s3_bucket_policy_change_event_names` | S3 bucket policy and related bucket-configuration actions to monitor. |
| `config_configuration_change_event_names` | AWS Config recorder and delivery channel changes to monitor. |
| `security_group_change_event_names` | EC2 security group mutation events to monitor. |
| `nacl_unauthorised_event_names` | Network ACL change events to monitor. |
| `ngw_unauthorised_event_names` | Internet gateway, customer gateway, and Transit Gateway change events to monitor. |
| `vpn_change_event_names` | VPN connection, VPN gateway, route, and customer gateway changes to monitor. |
| `rtb_unauthorised_actions` | Route table and route association change events to monitor. |
| `vpc_unauthorised_actions` | VPC and VPC peering change events to monitor. |
| `network_firewall_change_event_names` | AWS Network Firewall policy, rule group, firewall, TLS inspection, and subnet association changes to monitor. |
| `critical_event_names` | High-impact security service events that should trigger critical alarms. |
| `critical_role_trust_relationship_change_role_names` | IAM role names whose trust policies are considered critical and should be monitored closely. |
| `secrets_manager_cloudtrail_events` | Secrets Manager API actions used to detect access in MP-owned accounts and distinguish MP team use from non-MP-team use. |

## Metric Filters

### CIS and Baseline Filters

| Metric Filter Resource | Purpose |
| --- | --- |
| `aws_cloudwatch_log_metric_filter.unauthorised-api-calls` | Detects unauthorised API calls and access denied events, excluding a small set of known benign cases. |
| `aws_cloudwatch_log_metric_filter.sign-in-without-mfa` | Detects successful IAM user console logins that did not use MFA. |
| `aws_cloudwatch_log_metric_filter.root-account-usage` | Detects use of the root account outside AWS service events. |
| `aws_cloudwatch_log_metric_filter.iam-policy-changes` | Detects IAM policy mutations listed in `iam_policy_change_event_names` when they are not performed by trusted automation. |
| `aws_cloudwatch_log_metric_filter.cloudtrail-configuration-changes` | Detects CloudTrail trail creation, update, deletion, start, and stop logging operations. |
| `aws_cloudwatch_log_metric_filter.sign-in-failures` | Detects failed AWS console authentication attempts. |
| `aws_cloudwatch_log_metric_filter.cmk-removal` | Detects CMK disablement and scheduled deletion events in KMS. |
| `aws_cloudwatch_log_metric_filter.s3-bucket-policy-changes` | Detects monitored S3 bucket policy and related bucket configuration changes outside automation. |
| `aws_cloudwatch_log_metric_filter.config-configuration-changes` | Detects monitored AWS Config recorder and delivery channel changes outside automation. |
| `aws_cloudwatch_log_metric_filter.security-group-changes` | Detects monitored EC2 security group changes outside automation. |
| `aws_cloudwatch_log_metric_filter.nacl-changes` | Detects monitored network ACL changes outside automation. |
| `aws_cloudwatch_log_metric_filter.network-gateway-changes` | Detects monitored customer gateway, internet gateway, and Transit Gateway changes outside automation. |
| `aws_cloudwatch_log_metric_filter.route-table-changes` | Detects monitored route table and route changes outside automation. |
| `aws_cloudwatch_log_metric_filter.vpc-changes` | Detects monitored VPC and VPC peering changes outside automation. |

### Modernisation Platform-Specific Filters

| Metric Filter Resource | Purpose |
| --- | --- |
| `aws_cloudwatch_log_metric_filter.vpn-changes` | Detects monitored VPN, VPN gateway, VPN route, and customer gateway changes outside automation. |
| `aws_cloudwatch_log_metric_filter.network_firewall_changes` | Detects AWS Network Firewall changes in `core-network-services-production` outside automation. |
| `aws_cloudwatch_log_metric_filter.disable_alarm_actions_events` | Detects `DisableAlarmActions` calls outside automation. |
| `aws_cloudwatch_log_metric_filter.critical_events` | Detects a small set of high-impact security service events such as disabling Security Hub or deleting a GuardDuty detector. |
| `aws_cloudwatch_log_metric_filter.critical_role_trust_relationship_changes` | Detects trust policy changes to `MemberInfrastructureAccess` and `ModernisationPlatformAccess` outside automation. |
| `aws_cloudwatch_log_metric_filter.admin_role_usage` | Detects use of the `AdministratorAccess` role. |
| `aws_cloudwatch_log_metric_filter.admin_role_usage_by_mp_team` | Detects use of the `AdministratorAccess` role by the MP engineering team so it can be subtracted from the all-usage signal. |
| `aws_cloudwatch_log_metric_filter.admin_role_usage_outside_on_call_hours` | Detects `AdministratorAccess` usage during overnight and out-of-hours time windows. |
| `aws_cloudwatch_log_metric_filter.orgaccess_role_usage` | Detects use of `OrganizationAccountAccessRole`. |
| `aws_cloudwatch_log_metric_filter.iam_user_deletion_not_by_automation` | Detects IAM user deletion outside trusted automation roles. |
| `aws_cloudwatch_log_metric_filter.superadmin_role_usage` | Detects use of the `SuperAdmin` role in the `modernisation-platform` account only. |
| `aws_cloudwatch_log_metric_filter.superadmin_user_deletion` | Detects manual deletion of IAM users whose names end with `-superadmin` in the `modernisation-platform` account. |
| `aws_cloudwatch_log_metric_filter.superadmin_user_access_key_creation` | Detects manual access key creation for IAM users whose names end with `-superadmin` in the `modernisation-platform` account. |
| `aws_cloudwatch_log_metric_filter.secrets_manager_events_core_accounts_mp_all` | Detects monitored Secrets Manager events in MP-owned accounts when not triggered by trusted automation. |
| `aws_cloudwatch_log_metric_filter.secrets_manager_events_core_accounts_mp_team` | Detects the same Secrets Manager events when performed by MP team members, allowing the alarm to focus on non-MP-team usage. |
| `aws_cloudwatch_log_metric_filter.s3_object_deletions_excluding_tf_lock_files` | Detects S3 object deletion activity in core accounts, excluding individual `.tflock` object deletions. |
| `aws_cloudwatch_log_metric_filter.ec2_termination_in_core_shared_services` | Detects the event pattern currently configured for the `core-shared-services-production` termination alarm. |

## Metric Alarms

### Alarms Backed by Single Metrics

| Metric Alarm Resource | Purpose |
| --- | --- |
| `aws_cloudwatch_metric_alarm.unauthorised-api-calls` | Alerts on unauthorised API activity. |
| `aws_cloudwatch_metric_alarm.sign-in-without-mfa` | Alerts on successful IAM console sign-ins without MFA. |
| `aws_cloudwatch_metric_alarm.root-account-usage` | Alerts on root account usage. |
| `aws_cloudwatch_metric_alarm.iam-policy-changes` | Alerts on IAM policy changes outside trusted automation. |
| `aws_cloudwatch_metric_alarm.cloudtrail-configuration-changes` | Alerts on CloudTrail configuration changes. |
| `aws_cloudwatch_metric_alarm.sign-in-failures` | Alerts on repeated console sign-in failures. |
| `aws_cloudwatch_metric_alarm.cmk-removal` | Alerts on KMS CMK disablement or scheduled deletion. |
| `aws_cloudwatch_metric_alarm.s3-bucket-policy-changes` | Alerts on S3 bucket policy and related configuration changes. |
| `aws_cloudwatch_metric_alarm.config-configuration-changes` | Alerts on AWS Config recorder and delivery channel changes. |
| `aws_cloudwatch_metric_alarm.security-group-changes` | Alerts on security group changes. |
| `aws_cloudwatch_metric_alarm.nacl-changes` | Alerts on network ACL changes. |
| `aws_cloudwatch_metric_alarm.network-gateway-changes` | Alerts on internet gateway, customer gateway, and Transit Gateway changes. |
| `aws_cloudwatch_metric_alarm.vpn-changes` | Alerts on VPN and related gateway changes. |
| `aws_cloudwatch_metric_alarm.route-table-changes` | Alerts on route table and route changes. |
| `aws_cloudwatch_metric_alarm.vpc-changes` | Alerts on VPC and VPC peering changes. |
| `aws_cloudwatch_metric_alarm.network_firewall_changes` | Alerts on Network Firewall changes in `core-network-services-production`. |
| `aws_cloudwatch_metric_alarm.disable_alarm_actions_events` | Alerts when CloudWatch alarm actions are disabled outside automation. |
| `aws_cloudwatch_metric_alarm.critical_events_events` | Alerts on the high-impact critical events defined in `critical_event_names`. |
| `aws_cloudwatch_metric_alarm.critical_role_trust_relationship_changes` | Alerts on trust policy changes to critical access roles. |
| `aws_cloudwatch_metric_alarm.admin_role_usage` | Alerts on all `AdministratorAccess` usage captured by the base filter. |
| `aws_cloudwatch_metric_alarm.admin_role_usage_outside_on_call_outside_on_call_hours` | Alerts on `AdministratorAccess` usage outside core business and on-call hours. |
| `aws_cloudwatch_metric_alarm.orgaccess_role_usage` | Alerts on `OrganizationAccountAccessRole` usage. |
| `aws_cloudwatch_metric_alarm.iam_user_deletion_by_untrusted_role` | Alerts on IAM user deletion outside automation. |
| `aws_cloudwatch_metric_alarm.superadmin_role_usage` | Alerts on `SuperAdmin` role usage in the `modernisation-platform` account. |
| `aws_cloudwatch_metric_alarm.superadmin_user_deletion` | Alerts on manual deletion of `-superadmin` IAM users. |
| `aws_cloudwatch_metric_alarm.superadmin_user_access_key_creation` | Alerts on manual access key creation for `-superadmin` IAM users. |
| `aws_cloudwatch_metric_alarm.s3_object_deletions_excluding_tf_lock_files` | Alerts on S3 object deletions in monitored core-account contexts. |
| `aws_cloudwatch_metric_alarm.ec2_termination_in_core_shared_services` | Alerts on the event pattern currently configured for EC2 termination monitoring in `core-shared-services-production`. |

### Metric Math and Aggregate Alarms

| Metric Alarm Resource | Purpose |
| --- | --- |
| `aws_cloudwatch_metric_alarm.admin_role_usage_non_mp_team` | Uses metric math to subtract MP team `AdministratorAccess` usage from total `AdministratorAccess` usage, leaving only non-MP-team activity. |
| `aws_cloudwatch_metric_alarm.secrets_manager_core_account_events_not_by_mp_team` | Uses metric math to subtract MP team Secrets Manager activity from all non-automation Secrets Manager activity in MP-owned accounts. |
| `aws_cloudwatch_metric_alarm.privatelink_new_flow_count_all` | Alerts when the summed `NewFlowCount` across VPC endpoints exceeds the configured threshold. |
| `aws_cloudwatch_metric_alarm.privatelink_active_flow_count_all` | Alerts when the summed or averaged active VPC endpoint flow count exceeds the configured threshold. |
| `aws_cloudwatch_metric_alarm.privatelink_service_new_connection_count_all` | Alerts when the summed `NewConnectionCount` across PrivateLink services exceeds the configured threshold. |
| `aws_cloudwatch_metric_alarm.privatelink_service_active_connection_count_all` | Alerts when active PrivateLink service connection counts exceed the configured threshold. |

## Supporting Resources

| Resource | Purpose |
| --- | --- |
| `aws_kms_key.securityhub-alarms` | KMS key used to encrypt alarm messaging resources. |
| `aws_kms_alias.securityhub-alarms` | Alias for the primary alarms KMS key. |
| `aws_kms_key.securityhub_alarms_multi_region` | Multi-Region KMS key for alarm-related use cases. |
| `aws_kms_alias.securityhub_alarms_multi_region` | Alias for the multi-Region alarms KMS key. |
| `aws_sns_topic.securityhub-alarms` | Lower-priority SNS topic used by standard alarm actions. |
| `aws_sns_topic.high_priority_alarms_topic` | High-priority SNS topic used by urgent alarm actions. |
| `module.pagerduty_high_priority_alerts` | PagerDuty integration subscribed to the high-priority SNS topic. |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `tags` | Tags to apply to resources. | `map` | `{}` | no |

## Outputs

The module exports the created SNS topic ARNs, KMS ARNs, metric filter IDs, and alarm ARNs from [outputs.tf](./outputs.tf).

## Notes

- Some resources are created conditionally with `count` or `for_each`, so their presence depends on the current workspace and account classification.
- Some alarms intentionally use empty `alarm_actions` lists, which means they still evaluate and transition state but do not notify downstream actions.
- The README describes the resources as they are currently implemented in [main.tf](./main.tf), including rules whose semantics may warrant future refinement.

## Looking for Issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
