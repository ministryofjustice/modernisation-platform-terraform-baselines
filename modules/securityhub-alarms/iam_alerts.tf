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
  metric_name         = var.root_account_usage_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.4 - Ensure a log metric filter and alarm exist for IAM policy changes
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

# Alerts for changes to trust relationships of critical roles:
resource "aws_cloudwatch_log_metric_filter" "critical_role_trust_relationship_changes" {
  name           = var.critical_role_trust_relationship_changes_metric_filter_name
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"UpdateAssumeRolePolicy\") && (($.requestParameters.roleName = \"MemberInfrastructureAccess\") || ($.requestParameters.roleName = \"ModernisationPlatformAccess\")) && ${local.automation_role_filter}}"

  metric_transformation {
    name      = var.critical_role_trust_relationship_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "critical_role_trust_relationship_changes" {
  alarm_name        = var.critical_role_trust_relationship_changes_alarm_name
  alarm_description = "Monitors for trust relationship changes to MemberInfrastructureAccess or ModernisationPlatformAccess."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.critical_role_trust_relationship_changes_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# AdministratorAccess Alert Metric Filters and Alarms

# - All use of the SSO AdministratorAccess role by all.
resource "aws_cloudwatch_log_metric_filter" "admin_role_usage" {
  name           = var.admin_role_usage_metric_filter_name
  pattern        = "{ $.eventName = \"AssumeRoleWithSAML\" && $.requestParameters.roleArn = \"*AdministratorAccess*\" }"
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
  metric_name         = var.admin_role_usage_metric_filter_name
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
  alarm_actions     = local.low_priority_alarm_action

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
      metric_name = var.admin_role_usage_metric_filter_name
      namespace   = "LogMetrics"
      period      = 300
      stat        = "Sum"
    }
  }

  metric_query {
    id = "metric_mp_team"

    metric {
      metric_name = "${var.admin_role_usage_metric_filter_name}-mp-team-usage"
      namespace   = "LogMetrics"
      period      = 300
      stat        = "Sum"
    }
  }

  tags = var.tags
}

# All use of the SSO AdministratorAccess outside of core business & on-call hours.
resource "aws_cloudwatch_log_metric_filter" "admin_role_usage_outside_on_call_hours" {
  name           = "${var.admin_role_usage_metric_filter_name}-all-usage-outside-on-call-hours"
  pattern        = "{ $.eventName = \"AssumeRoleWithSAML\" && $.requestParameters.roleArn = \"*AdministratorAccess*\" && (($.eventTime = \"*T22:*\") || ($.eventTime = \"*T23:*\") || ($.eventTime = \"*T00:*\") || ($.eventTime = \"*T01:*\") || ($.eventTime = \"*T02:*\") || ($.eventTime = \"*T03:*\") || ($.eventTime = \"*T04:*\") || ($.eventTime = \"*T05:*\") || ($.eventTime = \"*T06:*\")) }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "${var.admin_role_usage_metric_filter_name}-all-usage-outside-on-call-hours"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "admin_role_usage_outside_on_call_hours" {
  alarm_name        = "${var.admin_role_usage_metric_filter_name}-all-usage-outside-on-call-hours"
  alarm_description = "Monitors for use of the Administrator role outside of core business and on-call hours."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "${var.admin_role_usage_metric_filter_name}-all-usage-outside-on-call-hours"
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
  metric_name         = var.orgaccess_role_usage_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# Filter & Alarm for the deletion of IAM users outside of trusted automation roles
resource "aws_cloudwatch_log_metric_filter" "iam_user_deletion_not_by_automation" {
  name           = var.iam_user_deletion_not_by_automation_metric_filter_name
  pattern        = "{ $.eventName = \"DeleteUser\" && ${local.automation_role_filter} }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.iam_user_deletion_not_by_automation_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_user_deletion_by_untrusted_role" {
  alarm_name        = var.iam_user_deletion_by_untrusted_role_alarm_name
  alarm_description = "Monitors for the deletion of IAM users other than via automation"
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.iam_user_deletion_not_by_automation_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# Filter & Alarm for use of the SuperAdmin role in the modernisation-platform account only.
resource "aws_cloudwatch_log_metric_filter" "superadmin_role_usage" {
  count          = local.is_mp_account ? 1 : 0
  name           = var.superadmin_role_usage_metric_filter_name
  pattern        = "{ $.eventName = \"AssumeRole\" && $.requestParameters.roleArn = \"*SuperAdmin*\" }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.superadmin_role_usage_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "superadmin_role_usage" {
  count             = local.is_mp_account ? 1 : 0
  alarm_name        = var.superadmin_role_usage_alarm_name
  alarm_description = "Monitors for use of the SuperAdmin role."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.superadmin_role_usage_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# Deletion of SuperAdmin Users in the modernisation-platform account manually by unknown roles
resource "aws_cloudwatch_log_metric_filter" "superadmin_user_deletion" {
  count          = local.is_mp_account ? 1 : 0
  name           = var.superadmin_user_deletion_metric_filter_name
  pattern        = "{($.eventName = \"DeleteUser\") && ($.requestParameters.userName = \"*-superadmin\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.superadmin_user_deletion_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "superadmin_user_deletion" {
  count             = local.is_mp_account ? 1 : 0
  alarm_name        = var.superadmin_user_deletion_alarm_name
  alarm_description = "Monitors for manual deletion of IAM users with the -superadmin suffix."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.superadmin_user_deletion_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# SuperAdmin IAM User - Access Key Creation not via automation
resource "aws_cloudwatch_log_metric_filter" "superadmin_user_access_key_creation" {
  count          = local.is_mp_account ? 1 : 0
  name           = var.superadmin_user_access_key_creation_metric_filter_name
  pattern        = "{($.eventName = \"CreateAccessKey\") && ($.requestParameters.userName = \"*-superadmin\") && ${local.automation_role_filter}}"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = var.superadmin_user_access_key_creation_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "superadmin_user_access_key_creation" {
  count             = local.is_mp_account ? 1 : 0
  alarm_name        = var.superadmin_user_access_key_creation_alarm_name
  alarm_description = "Monitors for creation of access keys of IAM users with the -superadmin suffix."
  alarm_actions     = local.low_priority_alarm_action

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.superadmin_user_access_key_creation_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}
