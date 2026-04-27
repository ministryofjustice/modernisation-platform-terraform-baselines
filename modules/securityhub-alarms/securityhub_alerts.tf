# Alerts for activities that disable alarm actions and other critical resources outside of automation
resource "aws_cloudwatch_log_metric_filter" "securityhub_events" {
  name           = "securityhub-events-alerting"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{((($.eventName = \"DisableSecurityHub\") || ($.eventName = \"DeleteDetector\") || ($.eventName = \"UpdateDetector\")) && ${local.automation_role_filter})}"

  metric_transformation {
    name      = "critical-events"
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "securityhub_events" {
  alarm_name        = "securityhub-events-alerting"
  alarm_description = "Monitors for SecurityHub being disabled and GuardDuty being disabled or materially changed."
  alarm_actions     = local.low_priority_alarm_action

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