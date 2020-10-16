output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.cloudtrail.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.cloudtrail.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.cloudtrail.arn
}
