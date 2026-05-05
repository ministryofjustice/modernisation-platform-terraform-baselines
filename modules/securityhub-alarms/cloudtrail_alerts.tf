# 3.5 - Ensure a log metric filter and alarm exist for CloudTrail configuration changes
resource "aws_cloudwatch_log_metric_filter" "cloudtrail-configuration-changes" {
  for_each       = toset(local.cloudtrail_configuration_change_event_names)
  name           = "${var.cloudtrail_configuration_changes_metric_filter_name}-${each.key}"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{($.eventName = \"${each.value}\") && ($.requestParameters.name = \"cloudtrail\") && ${local.automation_role_filter}}"

  metric_transformation {
    name      = var.cloudtrail_configuration_changes_metric_filter_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail-configuration-changes" {
  alarm_name        = var.cloudtrail_configuration_changes_alarm_name
  alarm_description = "Monitors for CloudTrail configuration changes."
  alarm_actions     = [aws_sns_topic.high_priority_alarms_topic.arn]

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
