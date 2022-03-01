output "sns_topic_arn" {
  value       = aws_sns_topic.securityhub-alarms.arn
  description = "Security benchmark Cloudwatch alarms SNS topic ARN"
}
