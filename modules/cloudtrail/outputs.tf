output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.cloudtrail.arn
}

output "s3_bucket_id" {
  value = module.cloudtrail-bucket.bucket.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.cloudtrail.arn
}
