
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
  metric_name         = var.unauthorised_api_calls_log_metric_filter_name
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
  metric_name         = var.sign_in_without_mfa_metric_filter_name
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
  metric_name         = var.sign_in_failures_metric_filter_name
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
  metric_name         = var.cmk_removal_metric_filter_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}

# 3.8 - Ensure a log metric filter and alarm exist for S3 bucket policy changes
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

# Alerts for Cloudwatch Alarm Actions being Disabled outside of automation
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
  alarm_name        = "disable-alarms-actions-events"
  alarm_description = "Monitors for CloudWatch alarm actions being disabled outside of automation"
  alarm_actions     = local.low_priority_alarm_action

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

# All Secrets Manager Actions in MP Accounts but not by MP Team Members and Not via Automation

# All events except by trusted automation roles
resource "aws_cloudwatch_log_metric_filter" "secrets_manager_events_core_accounts_mp_all" {
  count          = local.is_mp_workspace || local.is_mp_account ? 1 : 0
  name           = "secrets-manager-cloudtrail-events-mp-all"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{(((($.eventName = \"*Secret*\") || ($.eventName = \"*ResourcePolicy*\") || ($.eventName = \"RemoveRegionsFromReplication\") || ($.eventName = \"StopReplicationToReplica\")) && ($.readOnly = false) && ${local.automation_role_filter}))}"

  metric_transformation {
    name      = "secrets-manager-cloudtrail-events-mp-all"
    namespace = "LogMetrics"
    value     = 1
  }
}

# All non-automation events by MP Team members (which we will use to filter out from the alarm)
resource "aws_cloudwatch_log_metric_filter" "secrets_manager_events_core_accounts_mp_team" {
  count          = local.is_mp_workspace || local.is_mp_account ? 1 : 0
  name           = "secrets-manager-cloudtrail-events-mp-team"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{(((($.eventName = \"*Secret*\") || ($.eventName = \"*ResourcePolicy*\") || ($.eventName = \"RemoveRegionsFromReplication\") || ($.eventName = \"StopReplicationToReplica\")) && ($.readOnly = false) && $.requestParameters.principalTags.github_team = \"*modernisation-platform-engineers*\" && ${local.automation_role_filter}))}"

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
  alarm_actions     = local.low_priority_alarm_action

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

# Alerts for S3 file deletion in the MP Core Accounts
resource "aws_cloudwatch_log_metric_filter" "s3_object_deletions_excluding_tf_lock_files" {
  count          = local.is_mp_workspace || local.is_mp_account ? 1 : 0
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
  count             = local.is_mp_workspace || local.is_mp_account ? 1 : 0
  alarm_name        = "s3-object-deletions-excluding-tf-lock-files"
  alarm_description = "Monitors for S3 object deletions excluding Terraform state lock files in core accounts."
  alarm_actions     = local.low_priority_alarm_action

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

# Alert for termination of ec2s from core-shared-services-production not by automation
resource "aws_cloudwatch_log_metric_filter" "ec2_termination_in_core_shared_services" {
  count          = local.account_name == "core-shared-services" ? 1 : 0
  name           = "ec2-termination-in-core-shared-services"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventSource = \"ec2.amazonaws.com\") && ($.eventName = \"TerminateInstances\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = "ec2-termination-in-core-shared-services"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_termination_in_core_shared_services" {
  count             = local.account_name == "core-shared-services" ? 1 : 0
  alarm_name        = "ec2-termination-in-core-shared-services"
  alarm_description = "Monitors for termination of ec2 instances in core-shared-services"
  alarm_actions     = local.low_priority_alarm_action

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


