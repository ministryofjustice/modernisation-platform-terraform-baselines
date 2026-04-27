# 3.9 - Ensure a log metric filter and alarm exist for AWS Config configuration changes
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