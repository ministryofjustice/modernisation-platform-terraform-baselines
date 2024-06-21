output "sns_subscription_arn" {
  value = module.test_alerts.sns_subscription_arn["test_alarms"]
}

output "sns_topic_arn" {
  value = module.test_alerts.sns_topic_arn["test_alarms"]
}
