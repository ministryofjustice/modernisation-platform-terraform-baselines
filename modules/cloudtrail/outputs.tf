output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.cloudtrail.arn
}

output "s3_bucket" {
  value = module.cloudtrail-bucket.bucket
}

output "log_bucket" {
  value = module.cloudtrail-log-bucket.bucket
}

output "sns_topic_arn" {
  value = aws_sns_topic.cloudtrail.arn
}
