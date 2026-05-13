# Monitors for SecurityHub being disabled and GuardDuty being disabled or materially changed outside of automation
resource "aws_cloudwatch_log_metric_filter" "securityhub_events" {
  name           = var.securityhub_events_metric_filter_name
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{((($.eventName = \"DisableSecurityHub\") || ($.eventName = \"DeleteDetector\") || ($.eventName = \"UpdateDetector\")) && ${local.automation_role_filter})}"

  metric_transformation {
    name      = var.securityhub_events_metric_name
    namespace = "LogMetrics"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "securityhub_events" {
  alarm_name        = var.securityhub_events_alarm_name
  alarm_description = "Monitors for SecurityHub being disabled and GuardDuty being disabled or materially changed."
  alarm_actions     = [aws_sns_topic.high_priority_alarms_topic.arn]

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = var.securityhub_events_metric_name
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  tags = var.tags
}