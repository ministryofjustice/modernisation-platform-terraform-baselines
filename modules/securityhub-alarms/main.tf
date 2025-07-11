locals {
  mp_owned_workspaces = [
    "cooker-development",
    "example-development",
    "long-term-storage-production",
    "sprinkler-development",
    "testing-test",
    "^core-.*"
  ]

  is_workspace_matched = length(regexall(join("|", local.mp_owned_workspaces), terraform.workspace)) > 0

  alarm_action = local.is_workspace_matched ? [aws_sns_topic.securityhub-alarms.arn] : []
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
  pattern        = "{($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\" && ($.eventName != \"ListDelegatedAdministrators\") && ($.eventName != \"GetMacieSession\"))}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.unauthorised_api_calls_log_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorised-api-calls" {
  alarm_name        = var.unauthorised_api_calls_alarm_name
  alarm_description = "Monitors for unauthorised API calls."
  alarm_actions     = local.alarm_action

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
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.sign_in_without_mfa_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "sign-in-without-mfa" {
  alarm_name        = var.sign_in_without_mfa_alarm_name
  alarm_description = "Monitors for AWS Console sign-in without MFA."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

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
  log_group_name = "cloudtrail"

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
resource "aws_cloudwatch_log_metric_filter" "iam-policy-changes" {
  name           = var.iam_policy_changes_metric_filter_name
  pattern        = "{($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.iam_policy_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "iam-policy-changes" {
  alarm_name        = var.iam_policy_changes_alarm_name
  alarm_description = "Monitors for IAM policy changes."
  alarm_actions     = []

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.iam-policy-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.5 - Ensure a log metric filter and alarm exist for CloudTrail configuration changes
resource "aws_cloudwatch_log_metric_filter" "cloudtrail-configuration-changes" {
  name           = var.cloudtrail_configuration_changes_metric_filter_name
  pattern        = "{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.cloudtrail_configuration_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail-configuration-changes" {
  alarm_name        = var.cloudtrail_configuration_changes_alarm_name
  alarm_description = "Monitors for CloudTrail configuration changes."
  alarm_actions     = []

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.cloudtrail-configuration-changes.id
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
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.sign_in_failures_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "sign-in-failures" {
  alarm_name        = var.sign_in_failures_alarm_name
  alarm_description = "Monitors for AWS Console sign-in failures."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

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
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.cmk_removal_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "cmk-removal" {
  alarm_name        = var.cmk_removal_alarm_name
  alarm_description = "Monitors for AWS KMS customer-created CMK removal (deletion or disabled)."
  alarm_actions     = local.alarm_action

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
resource "aws_cloudwatch_log_metric_filter" "s3-bucket-policy-changes" {
  name           = var.s3_bucket_policy_changes_metric_filter_name
  pattern        = "{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.s3_bucket_policy_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "s3-bucket-policy-changes" {
  alarm_name        = var.s3_bucket_policy_changes_alarm_name
  alarm_description = "Monitors for AWS S3 bucket policy changes."
  alarm_actions     = []

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.s3-bucket-policy-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.9 - Ensure a log metric filter and alarm exist for AWS Config configuration changes
resource "aws_cloudwatch_log_metric_filter" "config-configuration-changes" {
  name           = var.config_configuration_changes_metric_filter_name
  pattern        = "{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.config_configuration_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "config-configuration-changes" {
  alarm_name        = var.config_configuration_changes_alarm_name
  alarm_description = "Monitors for AWS Config configuration changes."
  alarm_actions     = []

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.config-configuration-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.10 - Ensure a log metric filter and alarm exist for security group changes
resource "aws_cloudwatch_log_metric_filter" "security-group-changes" {
  name           = var.security_group_changes_metric_filter_name
  pattern        = "{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.security_group_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "security-group-changes" {
  alarm_name        = var.security_group_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 Security Group changes."
  alarm_actions     = []

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.security-group-changes.id
  namespace           = "LogMetrics"
  period              = "180"
  statistic           = "Sum"
  threshold           = "9"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.11 - Ensure a log metric filter and alarm exist for changes to Network Access Control Lists (NACL)
resource "aws_cloudwatch_log_metric_filter" "nacl-changes" {
  name           = var.nacl_changes_metric_filter_name
  pattern        = "{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.nacl_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "nacl-changes" {
  alarm_name        = var.nacl_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 Network Access Control Lists changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.nacl-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.12 - Ensure a log metric filter and alarm exist for changes to network gateways
resource "aws_cloudwatch_log_metric_filter" "network-gateway-changes" {
  name           = var.network_gateway_changes_metric_filter_name
  pattern        = "{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.network_gateway_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "network-gateway-changes" {
  alarm_name        = var.network_gateway_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 network gateway changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.network-gateway-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.13 - Ensure a log metric filter and alarm exist for route table changes
resource "aws_cloudwatch_log_metric_filter" "route-table-changes" {
  name           = var.route_table_changes_metric_filter_name
  pattern        = "{($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.route_table_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "route-table-changes" {
  alarm_name        = var.route_table_changes_alarm_name
  alarm_description = "Monitors for AWS EC2 route table changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.route-table-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.14 - Ensure a log metric filter and alarm exist for VPC changes
resource "aws_cloudwatch_log_metric_filter" "vpc-changes" {
  name           = var.vpc_changes_metric_filter_name
  pattern        = "{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.vpc_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc-changes" {
  alarm_name        = var.vpc_changes_alarm_name
  alarm_description = "Monitors for AWS VPC changes."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.vpc-changes.id
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}


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

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]
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

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]
  tags          = var.tags
}

# New Connection Count Alarm
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

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]
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

  alarm_actions = [aws_sns_topic.securityhub-alarms.arn]
  tags          = var.tags
}

# Alarm for use of the AdministratorAccess Role

resource "aws_cloudwatch_log_metric_filter" "admin_role_usage" {
  name           = var.admin_role_usage_metric_filter_name
  pattern        = "{ $.eventName = \"AssumeRoleWithSAML\" && $.requestParameters.roleArn = \"*AdministratorAccess*\" && $.requestParameters.principalTags.github_team = \"*modernisation-platform-engineers*\" }"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.admin_role_usage_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "admin_role_usage" {
  alarm_name        = var.admin_role_usage_alarm_name
  alarm_description = "Monitors for use of the AdministratorAccess role."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

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

# Alarm for use of the OrganizationAccountAccessRole
# Note that for this role we're not just looking for use of it by modernisation-platform-engineers github team, however the source log group is the same.

resource "aws_cloudwatch_log_metric_filter" "orgaccess_role_usage" {
  name           = var.orgaccess_role_usage_metric_filter_name
  pattern        = "{ $.eventName = \"AssumeRole*\" && $.requestParameters.roleArn = \"*OrganizationAccountAccessRole*\" && $.requestParameters.roleSessionName = \"*justice.gov.uk*\" }"
  log_group_name = "cloudtrail"

  metric_transformation {
    name      = var.orgaccess_role_usage_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "orgaccess_role_usage" {
  alarm_name        = var.orgaccess_role_usage_alarm_name
  alarm_description = "Monitors for use of the OrganizationAccountAccessRole role."
  alarm_actions     = [aws_sns_topic.securityhub-alarms.arn]

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
