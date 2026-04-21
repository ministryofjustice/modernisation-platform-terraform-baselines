# Fetch the environment definition from the modernisation-platform repo.
# count = 0 for the default (MP) workspace, which has no environments JSON.
data "http" "environment_definition" {
  count = terraform.workspace == "default" ? 0 : 1
  url   = "https://raw.githubusercontent.com/ministryofjustice/modernisation-platform/main/environments/${local.account_name}.json"
}

locals {
  mp_owned_workspaces = [
    "cooker-development",
    "example-development",
    "long-term-storage-production",
    "sprinkler-development",
    "testing-test",
    "^core-.*"
  ]

  is_mp_workspace = length(regexall(join("|", local.mp_owned_workspaces), terraform.workspace)) > 0

  # Derive the application name by stripping the trailing -<environment> suffix.
  account_name = terraform.workspace == "default" ? "" : replace(terraform.workspace, regex("-[^-]*$", terraform.workspace), "")

  # Decode the environments JSON. Falls back to empty map if unavailable.
  environment_definition = terraform.workspace == "default" ? null : try(
    jsondecode(data.http.environment_definition[0].response_body),
    null
  )

  # True when the account-type in the environments JSON is "member-unrestricted".
  member_unrestricted_account_prefixes = ["bichard7"]
  is_member_unrestricted = (
    try(local.environment_definition["account-type"], "") == "member-unrestricted" ||
    anytrue([for p in local.member_unrestricted_account_prefixes : startswith(terraform.workspace, "${p}-")])
  )

  # Extract the environment suffix (last segment after the final dash, e.g. "development")
  environment_name = terraform.workspace == "default" ? "" : regex("[^-]+$", terraform.workspace)

  # Find the access list for the current environment in the JSON
  current_environment_access = try(
    [for env in local.environment_definition["environments"] : env["access"]
      if env["name"] == local.environment_name
    ][0],
    []
  )

  # True when any access entry for this environment has level = "sandbox"
  is_sandbox_environment = length([
    for a in local.current_environment_access : a
    if try(a["level"], "") == "sandbox"
  ]) > 0

  # Combined suppression flag
  is_suppressed_account = local.is_member_unrestricted || local.is_sandbox_environment

  # Alarm actions

  # Low priority alarms action
  low_priority_alarm_action = [aws_sns_topic.securityhub-alarms.arn]

  # Low priority alarms enabled for MP-owned workspaces only
  mp_accounts_low_priority_alarm_action = local.is_mp_workspace ? local.low_priority_alarm_action : []

  # High-priority alarms disabled for suppressed accounts (member-unrestricted or sandbox), enabled everywhere else.
  high_priority_excluding_suppressed_alarm_action = local.is_suppressed_account ? [] : [aws_sns_topic.high_priority_alarms_topic.arn]

  # Low priority alarms disabled for suppressed accounts (member-unrestricted or sandbox), enabled everywhere else.
  low_priority_excluding_suppressed_alarm_action = local.is_suppressed_account ? [] : local.low_priority_alarm_action


  # Excludes known automation roles from triggering alarms, varying by account type:
  #   MP account (default workspace): uses github-actions OIDC role directly (no assume_role in provider)
  #   Core accounts (core-*):         uses ModernisationPlatformAccess only
  #   CP accounts (cloud-platform-*): uses ModernisationPlatformAccess, MemberInfrastructureAccess, and github-actions-development-cluster
  #   Member accounts (all others):   uses ModernisationPlatformAccess or MemberInfrastructureAccess
  is_mp_account   = terraform.workspace == "default"
  is_core_account = length(regexall("^core-", terraform.workspace)) > 0
  is_cp_account   = length(regexall("^cloud-platform-", terraform.workspace)) > 0

  automation_role_filter = (
    local.is_mp_account ? (
      "(($.userIdentity.type != \"AssumedRole\") || (($.userIdentity.sessionContext.sessionIssuer.userName != \"github-actions\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"github-actions-apply\")))"
      ) : local.is_core_account ? (
      "(($.userIdentity.type != \"AssumedRole\") || ($.userIdentity.sessionContext.sessionIssuer.userName != \"ModernisationPlatformAccess\"))"
      ) : local.is_cp_account ? (
      "(($.userIdentity.type != \"AssumedRole\") || (($.userIdentity.sessionContext.sessionIssuer.userName != \"ModernisationPlatformAccess\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"MemberInfrastructureAccess\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"github-actions-development-cluster\")))"
      ) : (
      "(($.userIdentity.type != \"AssumedRole\") || (($.userIdentity.sessionContext.sessionIssuer.userName != \"ModernisationPlatformAccess\") && ($.userIdentity.sessionContext.sessionIssuer.userName != \"MemberInfrastructureAccess\")))"
    )
  )
}

data "aws_caller_identity" "current" {}

# AWS CloudWatch doesn't support using the AWS-managed KMS key for publishing things from CloudWatch to SNS
# See: https://aws.amazon.com/premiumsupport/knowledge-center/cloudwatch-receive-sns-for-alarm-trigger/
resource "aws_kms_key" "securityhub-alarms" {
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  description                        = "SecurityHub alarms encryption key"
  enable_key_rotation                = true
  policy                             = data.aws_iam_policy_document.securityhub-alarms-kms.json
  tags                               = var.tags
}

resource "aws_kms_alias" "securityhub-alarms" {
  name          = var.securityhub_alarms_kms_name
  target_key_id = aws_kms_key.securityhub-alarms.id
}

# SecurityHub alarms KMS multi-Region
resource "aws_kms_key" "securityhub_alarms_multi_region" {
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  description                        = "SecurityHub alarms encryption key"
  enable_key_rotation                = true
  policy                             = data.aws_iam_policy_document.securityhub-alarms-kms.json
  tags                               = var.tags
  multi_region                       = true
}

resource "aws_kms_alias" "securityhub_alarms_multi_region" {
  name          = var.securityhub_alarms_multi_region_kms_name
  target_key_id = aws_kms_key.securityhub_alarms_multi_region.id
}

data "aws_iam_policy_document" "securityhub-alarms-kms" {

  #checkov:skip=CKV_AWS_356: "Permissions required by sec-hub"
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_109: "Ensure IAM policies does not allow permissions management / resource exposure without constraints - This is applied to a specific SNS topic"

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}

# SNS topic, required for remediation
resource "aws_sns_topic" "securityhub-alarms" {
  name              = var.securityhub_alarms_sns_topic_name
  kms_master_key_id = aws_kms_key.securityhub-alarms.arn
  tags              = var.tags
}

# SNS topic for high-priority rememdiation
resource "aws_sns_topic" "high_priority_alarms_topic" {
  name              = var.high_priority_sns_topic_name
  kms_master_key_id = aws_kms_key.securityhub-alarms.arn
  tags              = var.tags
}

# CloudWatch alarms for CIS
# 3.1 - Ensure a log metric filter and alarm exist for unauthorized API calls
resource "aws_cloudwatch_log_metric_filter" "unauthorised-api-calls" {
  name           = var.unauthorised_api_calls_log_metric_filter_name
  pattern        = "{((($.errorCode = \"*UnauthorizedOperation\") || (($.errorCode = \"AccessDenied*\") && ($.eventName != \"ListDelegatedAdministrators\") && ($.eventName != \"GetMacieSession\"))) && (($.userIdentity.type != \"AssumedRole\") || ($.userIdentity.sessionContext.sessionIssuer.userName != \"CortexXDRCloudApp\")))}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.unauthorised_api_calls_log_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorised-api-calls" {
  alarm_name        = var.unauthorised_api_calls_alarm_name
  alarm_description = "Monitors for unauthorised API calls."
  alarm_actions     = local.mp_accounts_low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorised-api-calls.id
  namespace           = "LogMetrics"
  period              = "180"
  statistic           = "Sum"
  threshold           = "10"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.2 - Ensure a log metric filter and alarm exist for Management Console sign-in without MFA
resource "aws_cloudwatch_log_metric_filter" "sign-in-without-mfa" {
  name           = var.sign_in_without_mfa_metric_filter_name
  pattern        = "{($.eventName=\"ConsoleLogin\") && ($.additionalEventData.MFAUsed !=\"Yes\") && ($.userIdentity.type =\"IAMUser\") && ($.responseElements.ConsoleLogin = \"Success\") }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.sign_in_without_mfa_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "sign-in-without-mfa" {
  alarm_name        = var.sign_in_without_mfa_alarm_name
  alarm_description = "Monitors for AWS Console sign-in without MFA."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.sign-in-without-mfa.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.3 - Ensure a log metric filter and alarm exist for usage of "root" account and
# 1.1 – Avoid the use of the "root" account
resource "aws_cloudwatch_log_metric_filter" "root-account-usage" {
  name           = var.root_account_usage_metric_filter_name
  pattern        = "{$.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !=\"AwsServiceEvent\"}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.root_account_usage_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "root-account-usage" {
  alarm_name        = var.root_account_usage_alarm_name
  alarm_description = "Monitors for root account usage."
  alarm_actions     = [aws_sns_topic.high_priority_alarms_topic.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.root-account-usage.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.4 - Ensure a log metric filter and alarm exist for IAM policy changes
locals {
  iam_policy_change_event_names = [
    "DeleteGroupPolicy",
    "DeleteRolePolicy",
    "DeleteUserPolicy",
    "PutGroupPolicy",
    "PutRolePolicy",
    "PutUserPolicy",
    "CreatePolicy",
    "DeletePolicy",
    "CreatePolicyVersion",
    "DeletePolicyVersion",
    "AttachRolePolicy",
    "DetachRolePolicy",
    "AttachUserPolicy",
    "DetachUserPolicy",
    "AttachGroupPolicy",
    "DetachGroupPolicy",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "iam-policy-changes" {
  for_each       = toset(local.iam_policy_change_event_names)
  name           = "${var.iam_policy_changes_metric_filter_name}-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = var.iam_policy_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "iam-policy-changes" {
  alarm_name        = var.iam_policy_changes_alarm_name
  alarm_description = "Monitors for IAM policy changes made outside of approved automation roles: ModernisationPlatformAccess, MemberInfrastructureAccess."
  alarm_actions     = local.low_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.iam_policy_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.5 - Ensure a log metric filter and alarm exist for CloudTrail configuration changes
locals {
  cloudtrail_configuration_change_event_names = [
    "CreateTrail",
    "UpdateTrail",
    "DeleteTrail",
    "StartLogging",
    "StopLogging",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "cloudtrail-configuration-changes" {
  for_each       = toset(local.cloudtrail_configuration_change_event_names)
  name           = "${var.cloudtrail_configuration_changes_metric_filter_name}-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = var.cloudtrail_configuration_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail-configuration-changes" {
  alarm_name        = var.cloudtrail_configuration_changes_alarm_name
  alarm_description = "Monitors for CloudTrail configuration changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.cloudtrail_configuration_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.6 - Ensure a log metric filter and alarm exist for AWS Management Console authentication failures
resource "aws_cloudwatch_log_metric_filter" "sign-in-failures" {
  name           = var.sign_in_failures_metric_filter_name
  pattern        = "{($.eventName=ConsoleLogin) && ($.errorMessage=\"Failed authentication\")}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.sign_in_failures_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "sign-in-failures" {
  alarm_name        = var.sign_in_failures_alarm_name
  alarm_description = "Monitors for AWS Console sign-in failures."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.sign-in-failures.id
  namespace           = "LogMetrics"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.7 - Ensure a log metric filter and alarm exist for disabling or scheduled deletion of customer created CMKs
resource "aws_cloudwatch_log_metric_filter" "cmk-removal" {
  name           = var.cmk_removal_metric_filter_name
  pattern        = "{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.cmk_removal_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "cmk-removal" {
  alarm_name        = var.cmk_removal_alarm_name
  alarm_description = "Monitors for AWS KMS customer-created CMK removal (deletion or disabled)."
  alarm_actions     = local.mp_accounts_low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.cmk-removal.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.8 - Ensure a log metric filter and alarm exist for S3 bucket policy changes
locals {
  s3_bucket_policy_change_event_names = [
    "PutBucketAcl",
    "PutBucketPolicy",
    "PutBucketCors",
    "PutBucketLifecycle",
    "PutBucketReplication",
    "DeleteBucketPolicy",
    "DeleteBucketCors",
    "DeleteBucketLifecycle",
    "DeleteBucketReplication",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "s3-bucket-policy-changes" {
  for_each       = toset(local.s3_bucket_policy_change_event_names)
  name           = "${var.s3_bucket_policy_changes_metric_filter_name}-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = var.s3_bucket_policy_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "s3-bucket-policy-changes" {
  alarm_name        = var.s3_bucket_policy_changes_alarm_name
  alarm_description = "Monitors for AWS S3 bucket policy changes."
  alarm_actions     = local.mp_accounts_low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.s3_bucket_policy_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.9 - Ensure a log metric filter and alarm exist for AWS Config configuration changes
locals {
  config_configuration_change_event_names = [
    "StopConfigurationRecorder",
    "DeleteDeliveryChannel",
    "PutDeliveryChannel",
    "PutConfigurationRecorder",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "config-configuration-changes" {
  for_each       = toset(local.config_configuration_change_event_names)
  name           = "${var.config_configuration_changes_metric_filter_name}-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = var.config_configuration_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "config-configuration-changes" {
  alarm_name        = var.config_configuration_changes_alarm_name
  alarm_description = "Monitors for AWS Config configuration changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.config_configuration_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.10 - Ensure a log metric filter and alarm exist for security group changes
locals {
  security_group_change_event_names = [
    "AuthorizeSecurityGroupIngress",
    "AuthorizeSecurityGroupEgress",
    "RevokeSecurityGroupIngress",
    "RevokeSecurityGroupEgress",
    "CreateSecurityGroup",
    "DeleteSecurityGroup",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "security-group-changes" {
  for_each       = toset(local.security_group_change_event_names)
  name           = "${var.security_group_changes_metric_filter_name}-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  metric_transformation {
    name      = var.security_group_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "security-group-changes" {
  alarm_name        = var.security_group_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 Security Group changes."
  alarm_actions     = local.low_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.security_group_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.11 - Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL)
locals {
  nacl_unauthorised_event_names = [
    "CreateNetworkAcl",
    "CreateNetworkAclEntry",
    "DeleteNetworkAcl",
    "DeleteNetworkAclEntry",
    "ReplaceNetworkAclEntry",
    "ReplaceNetworkAclAssociation"
  ]
}
resource "aws_cloudwatch_log_metric_filter" "nacl-changes" {
  for_each       = toset(local.nacl_unauthorised_event_names)
  name           = "${var.nacl_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.nacl_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl-changes" {
  alarm_name        = var.nacl_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 Network Access Control Lists changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.nacl_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.12 - Ensure a log metric filter and alarm exist for changes to network gateways, including Transit Gateways
locals {
  ngw_unauthorised_event_names = [
    "CreateCustomerGateway",
    "DeleteCustomerGateway",
    "AttachInternetGateway",
    "CreateInternetGateway",
    "DeleteInternetGateway",
    "DetachInternetGateway",
    "CreateTransitGateway",
    "DeleteTransitGateway",
    "ModifyTransitGateway",
    "CreateTransitGatewayRouteTable",
    "DeleteTransitGatewayRouteTable",
    "AssociateTransitGatewayRouteTable",
    "DisassociateTransitGatewayRouteTable",
    "EnableTransitGatewayRouteTablePropagation",
    "DisableTransitGatewayRouteTablePropagation",
    "CreateTransitGatewayRoute",
    "DeleteTransitGatewayRoute",
    "ReplaceTransitGatewayRoute",
    "CreateTransitGatewayVpcAttachment",
    "DeleteTransitGatewayVpcAttachment",
    "ModifyTransitGatewayVpcAttachment",
    "AcceptTransitGatewayVpcAttachment",
    "RejectTransitGatewayVpcAttachment",
    "CreateTransitGatewayPeeringAttachment",
    "DeleteTransitGatewayPeeringAttachment",
    "AcceptTransitGatewayPeeringAttachment",
    "RejectTransitGatewayPeeringAttachment",
    "CreateTransitGatewayConnect",
    "DeleteTransitGatewayConnect",
    "CreateTransitGatewayConnectPeer",
    "DeleteTransitGatewayConnectPeer"
  ]
}
resource "aws_cloudwatch_log_metric_filter" "network-gateway-changes" {
  for_each       = toset(local.ngw_unauthorised_event_names)
  name           = "${var.network_gateway_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.network_gateway_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "network-gateway-changes" {
  alarm_name        = var.network_gateway_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 network gateway changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.network_gateway_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.12.1 - Alerts for VPN changes made outside of trusted automation roles

locals {
  vpn_change_event_names = [
    "CreateVpnConnection",
    "DeleteVpnConnection",
    "ModifyVpnConnection",
    "CreateVpnConnectionRoute",
    "DeleteVpnConnectionRoute",
    "CreateVpnGateway",
    "DeleteVpnGateway",
    "AttachVpnGateway",
    "DetachVpnGateway",
    "CreateCustomerGateway",
    "DeleteCustomerGateway",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "vpn-changes" {
  for_each       = toset(local.vpn_change_event_names)
  name           = "vpn-changes-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "vpn-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "vpn-changes" {
  alarm_name        = "vpn-changes"
  alarm_description = "Monitors for VPN changes."
  alarm_actions     = [] #local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "vpn-changes"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.13 - Ensure a log metric filter and alarm exist for route table changes
locals {
  rtb_unauthorised_actions = [
    "CreateRoute",
    "CreateRouteTable",
    "ReplaceRoute",
    "ReplaceRouteTableAssociation",
    "DeleteRouteTable",
    "DeleteRoute",
    "DisassociateRouteTable"
  ]
}
resource "aws_cloudwatch_log_metric_filter" "route-table-changes" {
  for_each       = toset(local.rtb_unauthorised_actions)
  name           = "${var.route_table_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.route_table_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "route-table-changes" {
  alarm_name        = var.route_table_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 route table changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.route_table_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.14 - Ensure a log metric filter and alarm exist for VPC changes
locals {
  vpc_unauthorised_actions = [
    "CreateVpc",
    "DeleteVpc",
    "ModifyVpcAttribute",
    "AcceptVpcPeeringConnection",
    "CreateVpcPeeringConnection",
    "DeleteVpcPeeringConnection",
    "RejectVpcPeeringConnection",
    "AttachClassicLinkVpc",
    "DetachClassicLinkVpc",
    "DisableVpcClassicLink",
    "EnableVpcClassicLink"
  ]
}
resource "aws_cloudwatch_log_metric_filter" "vpc-changes" {
  for_each       = toset(local.vpc_unauthorised_actions)
  name           = "${var.vpc_changes_metric_filter_name}-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.vpc_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc-changes" {
  alarm_name        = var.vpc_changes_alarm_name
  alarm_description = "Monitors for AWS VPC changes."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.vpc_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}




# 3.15 - Alerts for ALL changes to Network Firewalls outside of trusted automation roles

locals {
  network_firewall_change_event_names = [
    "AssociateAvailabilityZones",
    "AssociateSubnets",
    "CreateFirewall",
    "CreateFirewallPolicy",
    "CreateRuleGroup",
    "CreateTLSInspectionConfiguration",
    "DeleteFirewall",
    "DeleteFirewallPolicy",
    "DeleteResourcePolicy",
    "DeleteRuleGroup",
    "DeleteTLSInspectionConfiguration",
    "DisassociateAvailabilityZones",
    "DisassociateSubnets",
    "PutResourcePolicy",
    "TagResource",
    "UntagResource",
    "UpdateFirewallDeleteProtection",
    "UpdateFirewallDescription",
    "UpdateFirewallEncryptionConfiguration",
    "UpdateFirewallPolicy",
    "UpdateFirewallPolicyChangeProtection",
    "UpdateLoggingConfiguration",
    "UpdateRuleGroup",
    "UpdateSubnetChangeProtection",
    "UpdateTLSInspectionConfiguration",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "network_firewall_changes" {
  for_each       = local.account_name == "core-network-services-production" ? toset(local.network_firewall_change_event_names) : toset([])
  name           = "network-firewall-changes-${each.key}"
  pattern        = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "network-firewall-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "network_firewall_changes" {
  alarm_name        = "network-firewall-changes"
  alarm_description = "Monitors for changes to Network Firewalls in core-network-services outside of automation"
	alarm_actions     = [] #local.high_priority_excluding_suppressed_alarm_action

	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods  = "1"
  metric_name         = "network-firewall-changes"
	namespace           = "LogMetrics"
	period              = "300"
	statistic           = "Sum"
	threshold           = "1"
	treat_missing_data  = "notBreaching"

	tags = var.tags
}


# 3.16 - Alerts for Cloudwatch Alarm Actions being Disabled outside of automation

resource "aws_cloudwatch_log_metric_filter" "disable_alarm_actions_events" {
  name           = "disable-alarm-actions-alerting"
	log_group_name = var.cloudtrail_log_group_name
  pattern        = "{($.eventName = \"DisableAlarmActions\") && ${local.automation_role_filter}}"

	metric_transformation {
    name      = "disable-alarm-actions"
		namespace = "LogMetrics"
		value     = 1
	}
}

resource "aws_cloudwatch_metric_alarm" "disable_alarm_actions_events" {
  alarm_name        = "disable-alarms-events"
  alarm_description = "Monitors for CloudWatch alarm actions being disabled outside of automation"
	alarm_actions     = [] #local.high_priority_excluding_suppressed_alarm_action

	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods  = "1"
  metric_name         = "disable-alarm-actions"
	namespace           = "LogMetrics"
	period              = "300"
	statistic           = "Sum"
	threshold           = "1"
	treat_missing_data  = "notBreaching"

	tags = var.tags
}


# 3.17 - Alerts for activities that disable alarm actions and other critical resources outside of automation

locals {
  critical_event_names = [
    "DisableSecurityHub",
    "DeleteDetector",
    "UpdateDetector",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "critical_events" {
  for_each       = toset(local.critical_event_names)
  name           = "activity-alerting-${each.key}"
	log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"

	metric_transformation {
    name      = "critical-events"
		namespace = "LogMetrics"
		value     = 1
	}
}

resource "aws_cloudwatch_metric_alarm" "critical_events_events" {
  alarm_name        = "disable-alarms-events"
  alarm_description = "Monitors for SecurityHub being disabled and GuardDuty being disabled or materially changed."
	alarm_actions     = [] #local.high_priority_excluding_suppressed_alarm_action

	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods  = "1"
  metric_name         = "critical-events"
	namespace           = "LogMetrics"
	period              = "300"
	statistic           = "Sum"
	threshold           = "1"
	treat_missing_data  = "notBreaching"

	tags = var.tags
}

# 3.18 - Alerts for changes to trust relationships of critical roles:

locals {
  critical_role_trust_relationship_change_role_names = [
    "MemberInfrastructureAccess",
    "ModernisationPlatformAccess",
  ]
}

resource "aws_cloudwatch_log_metric_filter" "critical_role_trust_relationship_changes" {
  for_each       = toset(local.critical_role_trust_relationship_change_role_names)
  name           = "critical-role-trust-relationship-changes-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"UpdateAssumeRolePolicy\") && ($.requestParameters.roleName = \"${each.value}\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = "critical-role-trust-relationship-changes"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "critical_role_trust_relationship_changes" {
  alarm_name        = "critical-role-trust-relationship-changes"
  alarm_description = "Monitors for trust relationship changes to MemberInfrastructureAccess or ModernisationPlatformAccess."
  alarm_actions     = [] # local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "critical-role-trust-relationship-changes"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.19 - Alerts for Private Link Changes

resource "aws_cloudwatch_metric_alarm" "privatelink_new_flow_count_all" {
  alarm_name          = var.privatelink_new_flow_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "100" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of new flows across all VPC endpoints."

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total New Flows"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "NewFlowCount"
      namespace   = "AWS/VpcEndpoints"
      period      = 60
      stat        = "Sum"
    }
  }

  alarm_actions = local.low_priority_alarm_action
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "privatelink_active_flow_count_all" {
  alarm_name          = var.privatelink_active_flow_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "1000" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of active flows across all VPC endpoints."

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total Active Flows"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ActiveFlowCount"
      namespace   = "AWS/VpcEndpoints"
      period      = 60
      stat        = "Average"
    }
  }

  alarm_actions = local.low_priority_alarm_action
  tags          = var.tags
}

# 3.20 - New Connection Count Alarm

resource "aws_cloudwatch_metric_alarm" "privatelink_service_new_connection_count_all" {
  alarm_name          = var.privatelink_service_new_connection_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "100" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of new connections across all VPC Endpoint Services."

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total New Connections"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "NewConnectionCount"
      namespace   = "AWS/PrivateLinkServices"
      period      = 60
      stat        = "Sum"
    }
  }

  alarm_actions = local.low_priority_alarm_action
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "privatelink_service_active_connection_count_all" {
  alarm_name          = var.privatelink_service_active_connection_count_all_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = "1000" # Adjust this threshold as needed
  alarm_description   = "This alarm monitors the total number of active connections across all VPC Endpoint Services."

  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    label       = "Total Active Connections"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "ActiveConnectionCount"
      namespace   = "AWS/PrivateLinkServices"
      period      = 60
      stat        = "Average"
    }
  }

  alarm_actions = local.low_priority_alarm_action
  tags          = var.tags
}

# 3.21 - AdministratorAccess Alert Metric Filters and Alarms

# - All use of the SSO AdministratorAccess role by all.

resource "aws_cloudwatch_log_metric_filter" "admin_role_usage" {
  name           = var.admin_role_usage_metric_filter_name
  pattern        = "{ $.eventName = \"AssumeRoleWithSAML\" && $.requestParameters.roleArn = \"*AdministratorAccess*\" && $.requestParameters.principalTags.github_team = \"*modernisation-platform-engineers*\" }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.admin_role_usage_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "admin_role_usage" {
  alarm_name        = var.admin_role_usage_alarm_name
  alarm_description = "Monitors for use of the AdministratorAccess role."
  alarm_actions     = local.low_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.admin_role_usage.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# - Alarm for use of the AdministratorAccess role across all accounts except the MP team.

resource "aws_cloudwatch_log_metric_filter" "admin_role_usage_by_mp_team" {
  name           = "${var.admin_role_usage_metric_filter_name}-mp-team-usage"
  pattern        = "{ $.eventName = \"AssumeRoleWithSAML\" && $.requestParameters.roleArn = \"*AdministratorAccess*\" && $.requestParameters.principalTags.github_team = \"*modernisation-platform-engineers*\" }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "${var.admin_role_usage_metric_filter_name}-mp-team-usage"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "admin_role_usage_non_mp_team" {
  alarm_name        = "${var.admin_role_usage_alarm_name}-non-mp-team"
  alarm_description = "Monitors for use of the AdministratorAccess role by principals outside the MP team."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "FILL(metric_all, 0) - FILL(metric_mp_team, 0)"
    label       = "AdministratorAccess usage excluding MP team"
    return_data = true
  }

  metric_query {
    id = "metric_all"

    metric {
      metric_name = aws_cloudwatch_log_metric_filter.admin_role_usage.id
      namespace   = "LogMetrics"
      period      = 300
      stat        = "Sum"
    }
  }

  metric_query {
    id = "metric_mp_team"

    metric {
      metric_name = aws_cloudwatch_log_metric_filter.admin_role_usage_by_mp_team.id
      namespace   = "LogMetrics"
      period      = 300
      stat        = "Sum"
    }
  }

  tags = var.tags
}

# 3.22 - All use of the SSO AdministratorAccess outside of core business & on-call hours.

resource "aws_cloudwatch_log_metric_filter" "admin_role_usage_outside_on_call_hours" {
  name           = "${var.admin_role_usage_metric_filter_name}-all-usage-outside-on-call-hours"
  pattern        = "{ $.eventName = \"AssumeRoleWithSAML\" && $.requestParameters.roleArn = \"*AdministratorAccess*\" && (($.eventTime = \"*T22:*\") || ($.eventTime = \"*T23:*\") || ($.eventTime = \"*T00:*\") || ($.eventTime = \"*T01:*\") || ($.eventTime = \"*T02:*\") || ($.eventTime = \"*T03:*\") || ($.eventTime = \"*T04:*\") || ($.eventTime = \"*T05:*\") || ($.eventTime = \"*T06:*\")) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "${var.admin_role_usage_metric_filter_name}-all-usage-outside-on-call"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "admin_role_usage_outside_on_call_outside_on_call_hours" {
  alarm_name        = "${var.admin_role_usage_metric_filter_name}-all-usage-outside-on-call-hours"
  alarm_description = "Monitors for use of the Administrator role outside of core business and on-call hours."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.admin_role_usage_outside_on_call_hours.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}


# 3.23 - Alarm for use of the OrganizationAccountAccessRole
# Note that for this role we're not just looking for use of it by modernisation-platform-engineers github team, however the source log group is the same.

resource "aws_cloudwatch_log_metric_filter" "orgaccess_role_usage" {
  name           = var.orgaccess_role_usage_metric_filter_name
  pattern        = "{ $.eventName = \"AssumeRole*\" && $.requestParameters.roleArn = \"*OrganizationAccountAccessRole*\" && $.requestParameters.roleSessionName = \"*justice.gov.uk*\" }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.orgaccess_role_usage_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "orgaccess_role_usage" {
  alarm_name        = var.orgaccess_role_usage_alarm_name
  alarm_description = "Monitors for use of the OrganizationAccountAccessRole role."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.orgaccess_role_usage.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}


# 3.24 - Filter & Alarm for the deletion of IAM users not via automation roles

resource "aws_cloudwatch_log_metric_filter" "iam_user_deletion_not_by_automation" {
  name           = "iam-user-deletion-not-by-automation"
  pattern        = "{ $.eventName = \"DeleteUser\" && ${local.automation_role_filter} }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "iam-user-deletion-not-by-automation"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_user_deletion_by_untrusted_role" {
  alarm_name        = "iam-user-deletion-by-untrusted-role"
  alarm_description = "Monitors for the deletion of IAM users other than via automation"
  alarm_actions     = [] #local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "iam-user-deletion-not-by-automation"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}


# 3.25 - Filter & Alarm for use of the SuperAdmin role in the modernisation-platform account only.

resource "aws_cloudwatch_log_metric_filter" "superadmin_role_usage" {
  count          = local.account_name == "modernisation-platform" ? 1 : 0
  name           = "modernisation-platform-superadmin-role-usage"
  pattern        = "{ $.eventName = \"AssumeRole\" && $.requestParameters.roleArn = \"*SuperAdmin*\" }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "modernisation-platform-superadmin-role-usage"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "superadmin_role_usage" {
  count             = local.account_name == "modernisation-platform" ? 1 : 0
  alarm_name        = "modernisation-platform-superadmin-role-usage"
  alarm_description = "Monitors for use of the SuperAdmin role."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "modernisation-platform-superadmin-role-usage"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.26 - Deletion of SuperAdmin Users in the modernisation-platform account manually by unknown roles

resource "aws_cloudwatch_log_metric_filter" "superadmin_user_deletion" {
  count          = local.account_name == "modernisation-platform" ? 1 : 0
  name           = "modernisation-platform-superadmin-user-deletion"
  pattern        = "{($.eventName = \"DeleteUser\") && ($.requestParameters.userName = \"*-superadmin\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "modernisation-platform-superadmin-user-deletion"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "superadmin_user_deletion" {
  count             = local.account_name == "modernisation-platform" ? 1 : 0
  alarm_name        = "modernisation-platform-superadmin-user-deletion"
  alarm_description = "Monitors for manual deletion of IAM users with the -superadmin suffix."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "modernisation-platform-superadmin-user-deletion"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.27 - SuperAdmin IAM User - Access Key Creation not via automation

resource "aws_cloudwatch_log_metric_filter" "superadmin_user_access_key_creation" {
  count          = local.account_name == "modernisation-platform" ? 1 : 0
  name           = "modernisation-platform-superadmin-user-access-key-creation"
  pattern        = "{($.eventName = \"CreateAccessKey\") && ($.requestParameters.userName = \"*-superadmin\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "modernisation-platform-superadmin-user-access-key-creation"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "superadmin_user_access_key_creation" {
  count             = local.account_name == "modernisation-platform" ? 1 : 0
  alarm_name        = "modernisation-platform-superadmin-user-access-key-creation"
  alarm_description = "Monitors for creation of access keys of IAM users with the -superadmin suffix."
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "modernisation-platform-superadmin-user-access-key-creation"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}


# 3.28 - All Secrets Manager Actions in MP Accounts but not by MP Team Members and Not via Automation

locals {
  secrets_manager_cloudtrail_events = [
    "BatchGetSecretValue",
    "CancelRotateSecret",
    "CreateSecret",
    "DeleteResourcePolicy",
    "DeleteSecret",
    "DescribeSecret",
    "GetRandomPassword",
    "GetResourcePolicy",
    "GetSecretValue",
    "ListSecrets",
    "ListSecretVersionIds",
    "PutResourcePolicy",
    "PutSecretValue",
    "RemoveRegionsFromReplication",
    "ReplicateSecretToRegions",
    "RestoreSecret",
    "RotateSecret",
    "StopReplicationToReplica",
    "TagResource",
    "UntagResource",
    "UpdateSecret",
    "UpdateSecretVersionStage",
    "ValidateResourcePolicy",
  ]
}

# All events except by trusted automation roles
resource "aws_cloudwatch_log_metric_filter" "secrets_manager_events_core_accounts_mp_all" {
  for_each       = local.is_mp_workspace || local.account_name == "modernisation-platform" ? toset(local.secrets_manager_cloudtrail_events) : toset([])
  name           = "secrets-manager-cloudtrail-events-mp-all-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = "secrets-manager-cloudtrail-events-mp-all"
    namespace = "LogMetrics"
    value     = 1
  }
}

# All non-automation events by MP Team members (which we will use to filter out from the alarm)
resource "aws_cloudwatch_log_metric_filter" "secrets_manager_events_core_accounts_mp_team" {
  for_each       = local.is_mp_workspace || local.account_name == "modernisation-platform" ? toset(local.secrets_manager_cloudtrail_events) : toset([])
  name           = "secrets-manager-cloudtrail-events-mp-team${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && $.requestParameters.principalTags.github_team = \"*modernisation-platform-engineers*\" && ${local.automation_role_filter}}"

  metric_transformation {
    name      = "secrets-manager-cloudtrail-events-mp-team"
    namespace = "LogMetrics"
    value     = 1
  }
}

# Alarm that generates alerts if actions on MP accounts are:
# 1. In an MP owned account, but
# 2. Is not by the MP team, and
# 3. Is not by an automation role

resource "aws_cloudwatch_metric_alarm" "secrets_manager_core_account_events_not_by_mp_team" {
  count             = local.is_mp_workspace || local.account_name == "modernisation-platform" ? 1 : 0
  alarm_name        = "secrets-manager-events-core-account-non-mp-team"
  alarm_description = "Monitors for the use of non-automation Secrets Manager events by principals outside the MP team."
  alarm_actions     = [] #local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "FILL(metric_sm_core_all, 0) - FILL(metric_sm_core_mp_team, 0)"
    label       = "Secrets Manager usage in core accounts excluding automation and MP team"
    return_data = true
  }

  metric_query {
    id = "metric_sm_core_all"

    metric {
      metric_name = "secrets-manager-cloudtrail-events-mp-all"
      namespace   = "LogMetrics"
      period      = 300
      stat        = "Sum"
    }
  }

  metric_query {
    id = "metric_sm_core_mp_team"

    metric {
      metric_name = "secrets-manager-cloudtrail-events-mp-team"
      namespace   = "LogMetrics"
      period      = 300
      stat        = "Sum"
    }
  }

  tags = var.tags
}

# 3.29 - Alerts for S3 file deletion in MP Core Accounts

resource "aws_cloudwatch_log_metric_filter" "s3_object_deletions_excluding_tf_lock_files" {
  count          = local.is_core_account ? 1 : 0
  name           = "s3-object-deletions-excluding-tf-lock-files"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventSource = \"s3.amazonaws.com\") && (((($.eventName = \"DeleteObject\") && ($.requestParameters.key != \"*.tflock\"))) || ($.eventName = \"DeleteObjects\"))}"

  metric_transformation {
    name      = "s3-object-deletions-excluding-tf-lock-files"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_object_deletions_excluding_tf_lock_files" {
  count             = local.is_mp_workspace || local.account_name == "modernisation-platform" ? 1 : 0
  alarm_name        = "s3-object-deletions-excluding-tf-lock-files"
  alarm_description = "Monitors for S3 object deletions excluding Terraform state lock files in core accounts other than core-shared-services."
  alarm_actions     = [] #local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "s3-object-deletions-excluding-tf-lock-files"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.30 - Alert for termination of ec2s from core-shared-services-production not by automation

resource "aws_cloudwatch_log_metric_filter" "ec2_termination_in_core_shared_services" {
  count          = local.account_name == "core-shared-services-production" ? 1 : 0
  name           = "ec2-termination-in-core-shared-services"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"DeleteObjects\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = "ec2-termination-in-core-shared-services"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_termination_in_core_shared_services" {
  count          = local.account_name == "core-shared-services-production" ? 1 : 0
  alarm_name        = "ec2-termination-in-core-shared-services"
  alarm_description = "Monitors for termination of ec2 instances in core-shared-services"
  alarm_actions     = local.high_priority_excluding_suppressed_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ec2-termination-in-core-shared-services"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}


# High Priority PagerDuty Notifications
# This adds pagerduty ingration for alarms alerting to the high-priority slack channel.

module "pagerduty_high_priority_alerts" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  depends_on = [
    aws_sns_topic.high_priority_alarms_topic
  ]
  sns_topics                = compact([aws_sns_topic.high_priority_alarms_topic.name])
  pagerduty_integration_key = var.high_priority_pagerduty_key
}
