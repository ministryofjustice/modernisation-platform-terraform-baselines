output "sns_topic_arn" {
  value       = aws_sns_topic.default.arn
  description = "Config SNS topic ARN"
}
