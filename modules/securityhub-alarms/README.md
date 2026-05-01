# SecurityHub Alarms

Terraform module for creating CloudWatch log metric filters and CloudWatch alarms used by Modernisation Platform baseline accounts. The module includes the original CIS-style `3.x` CloudTrail-backed controls as well as Modernisation Platform-specific detections for privileged role usage, Secrets Manager activity, Security Hub and GuardDuty changes, PrivateLink activity, and other high-value events.

## Usage

```hcl
module "securityhub-alarms" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/securityhub-alarms"
}
```

## File Layout

The module is intentionally split by concern rather than keeping all resources in a single file.

| File | Purpose |
| --- | --- |
| `locals.tf` | Shared data sources and all local values used across the module, including workspace/account classification, alarm action routing, automation role filtering, and event-name lists for `for_each` metric filters. |
| `sns.tf` | KMS keys, aliases, SNS topics, and the PagerDuty integration module used by the alarms. |
| `general_alerts.tf` | General CloudTrail-backed alarms such as unauthorised API calls, sign-in without MFA, sign-in failures, CMK removal, S3 bucket policy changes, alarm action disabling, and Secrets Manager activity alerts. |
| `cloudtrail_alerts.tf` | CloudTrail configuration change metric filters and alarms. |
| `config_alerts.tf` | AWS Config configuration change metric filters and alarms. |
| `iam_alerts.tf` | IAM and privileged access alerts including root usage, IAM policy changes, trust relationship changes, AdministratorAccess role usage, OrganizationAccountAccessRole usage, IAM user deletion, and SuperAdmin activity. |
| `network_alerts.tf` | Network-related alerts including security group, NACL, gateway, transit gateway, VPN, route table, VPC, Network Firewall, and PrivateLink alarms. |
| `securityhub_alerts.tf` | Security service protection alerts such as Security Hub and GuardDuty disablement or detector changes. |
| `outputs.tf` | Exported values from the module. |
| `variables.tf` | Module inputs used to name resources and configure alerting behaviour. |
| `versions.tf` | Terraform and provider version constraints. |

## What This Module Creates

The module creates:

- KMS keys and aliases used to encrypt alarm SNS topics.
- A standard SNS topic for lower-priority alarms.
- A high-priority SNS topic for urgent alarms.
- CloudWatch log metric filters over the account CloudTrail log group.
- CloudWatch metric alarms backed by either direct metrics or metric math.
- A PagerDuty integration subscribed to the high-priority SNS topic.

## Alarm Coverage By File

| File | Metric filters | Metric alarms |
| --- | --- | --- |
| `general_alerts.tf` | `unauthorised-api-calls`, `sign-in-without-mfa`, `sign-in-failures`, `cmk-removal`, `s3-bucket-policy-changes`, `disable_alarm_actions_events`, `secrets_manager_events_core_accounts_mp_all`, `secrets_manager_events_core_accounts_mp_team`, `s3_object_deletions_excluding_tf_lock_files`, `ec2_termination_in_core_shared_services` | `unauthorised-api-calls`, `sign-in-without-mfa`, `sign-in-failures`, `cmk-removal`, `s3-bucket-policy-changes`, `disable_alarm_actions_events`, `secrets_manager_core_account_events_not_by_mp_team`, `s3_object_deletions_excluding_tf_lock_files`, `ec2_termination_in_core_shared_services` |
| `cloudtrail_alerts.tf` | `cloudtrail-configuration-changes` | `cloudtrail-configuration-changes` |
| `config_alerts.tf` | `config-configuration-changes` | `config-configuration-changes` |
| `iam_alerts.tf` | `root-account-usage`, `iam-policy-changes`, `critical_role_trust_relationship_changes`, `admin_role_usage`, `admin_role_usage_by_mp_team`, `admin_role_usage_outside_on_call_hours`, `orgaccess_role_usage`, `iam_user_deletion_not_by_automation`, `superadmin_role_usage`, `superadmin_user_deletion`, `superadmin_user_access_key_creation` | `root-account-usage`, `iam-policy-changes`, `critical_role_trust_relationship_changes`, `admin_role_usage`, `admin_role_usage_non_mp_team`, `admin_role_usage_outside_on_call_hours`, `orgaccess_role_usage`, `iam_user_deletion_by_untrusted_role`, `superadmin_role_usage`, `superadmin_user_deletion`, `superadmin_user_access_key_creation` |
| `network_alerts.tf` | `security-group-changes`, `nacl-changes`, `network-gateway-changes`, `transit-gateway-changes`, `vpn-changes`, `route-table-changes`, `vpc-changes`, `network_firewall_changes` | `security-group-changes`, `nacl-changes`, `network-gateway-changes`, `transit-gateway-changes`, `vpn-changes`, `route-table-changes`, `vpc-changes`, `network_firewall_changes`, `privatelink_new_flow_count_all`, `privatelink_active_flow_count_all`, `privatelink_service_new_connection_count_all`, `privatelink_service_active_connection_count_all` |
| `securityhub_alerts.tf` | `securityhub_events` | `securityhub_events` |

## CIS Metric Filters And Alarms

To comply with the CIS AWS Foundations Benchmark security standard, the following AWS CloudWatch log metric filters were added. These are flagged with a 3.x numbering convention in the comment.

This module also covers [1.1 - Avoid the use of the "root" account](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.1-remediation) as a by-product of the `3.3` root-account usage alarm.

| Reference | AWS documentation | File | Metric filter | Metric alarm | Summary |
| --- | --- | --- | --- | --- | --- |
| `3.1` | [CIS 3.1 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.1-remediation) | `general_alerts.tf` | `aws_cloudwatch_log_metric_filter.unauthorised-api-calls` | `aws_cloudwatch_metric_alarm.unauthorised-api-calls` | Unauthorised API calls and access denied events. |
| `3.2` | [CIS 3.2 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.2-remediation) | `general_alerts.tf` | `aws_cloudwatch_log_metric_filter.sign-in-without-mfa` | `aws_cloudwatch_metric_alarm.sign-in-without-mfa` | Successful IAM user console sign-in without MFA. |
| `3.3` | [CIS 3.3 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.3-remediation) | `iam_alerts.tf` | `aws_cloudwatch_log_metric_filter.root-account-usage` | `aws_cloudwatch_metric_alarm.root-account-usage` | Root account usage outside service events. |
| `3.4` | [CIS 3.4 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.4-remediation) | `iam_alerts.tf` | `aws_cloudwatch_log_metric_filter.iam-policy-changes` | `aws_cloudwatch_metric_alarm.iam-policy-changes` | IAM policy changes outside trusted automation. |
| `3.5` | [CIS 3.5 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.5-remediation) | `cloudtrail_alerts.tf` | `aws_cloudwatch_log_metric_filter.cloudtrail-configuration-changes` | `aws_cloudwatch_metric_alarm.cloudtrail-configuration-changes` | CloudTrail trail configuration changes. |
| `3.6` | [CIS 3.6 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.6-remediation) | `general_alerts.tf` | `aws_cloudwatch_log_metric_filter.sign-in-failures` | `aws_cloudwatch_metric_alarm.sign-in-failures` | AWS Management Console authentication failures. |
| `3.7` | [CIS 3.7 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.7-remediation) | `general_alerts.tf` | `aws_cloudwatch_log_metric_filter.cmk-removal` | `aws_cloudwatch_metric_alarm.cmk-removal` | Disabling or scheduled deletion of customer-created CMKs. |
| `3.8` | [CIS 3.8 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.8-remediation) | `general_alerts.tf` | `aws_cloudwatch_log_metric_filter.s3-bucket-policy-changes` | `aws_cloudwatch_metric_alarm.s3-bucket-policy-changes` | S3 bucket policy and related bucket configuration changes. |
| `3.9` | [CIS 3.9 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.9-remediation) | `config_alerts.tf` | `aws_cloudwatch_log_metric_filter.config-configuration-changes` | `aws_cloudwatch_metric_alarm.config-configuration-changes` | AWS Config recorder and delivery channel changes. |
| `3.10` | [CIS 3.10 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.10-remediation) | `network_alerts.tf` | `aws_cloudwatch_log_metric_filter.security-group-changes` | `aws_cloudwatch_metric_alarm.security-group-changes` | Security group changes. |
| `3.11` | [CIS 3.11 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.11-remediation) | `network_alerts.tf` | `aws_cloudwatch_log_metric_filter.nacl-changes` | `aws_cloudwatch_metric_alarm.nacl-changes` | Network ACL changes. |
| `3.12` | [CIS 3.12 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.12-remediation) | `network_alerts.tf` | `aws_cloudwatch_log_metric_filter.network-gateway-changes` | `aws_cloudwatch_metric_alarm.network-gateway-changes` | Network gateway changes. |
| `3.13` | [CIS 3.13 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.13-remediation) | `network_alerts.tf` | `aws_cloudwatch_log_metric_filter.route-table-changes` | `aws_cloudwatch_metric_alarm.route-table-changes` | Route table changes. |
| `3.14` | [CIS 3.14 remediation](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html/cis-3.14-remediation) | `network_alerts.tf` | `aws_cloudwatch_log_metric_filter.vpc-changes` | `aws_cloudwatch_metric_alarm.vpc-changes` | VPC and VPC peering changes. |

Security Hub has dedicated controls which check that these alarms and metric filters exist to show compliance with the benchmark. These controls were [removed from later benchmark versions](https://docs.aws.amazon.com/securityhub/latest/userguide/cis-aws-foundations-benchmark.html), such as v3.0.0.

## Notes

- Some resources are conditional through `count` or `for_each`, so the exact set of created alarms depends on the current workspace and account classification.
- Some alarms intentionally use empty `alarm_actions` lists. Those alarms still evaluate and change state, but they do not publish notifications.

## Outputs

The module exports SNS topic ARNs, KMS ARNs, metric filter IDs, and alarm ARNs from `outputs.tf`.

Most alert resource names are configurable through inputs in `variables.tf`. For alerts where the CloudWatch metric name differs from the log metric filter resource name, the module exposes separate `*_metric_name` inputs alongside the usual `*_metric_filter_name` and `*_alarm_name` inputs.

## Looking for Issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
