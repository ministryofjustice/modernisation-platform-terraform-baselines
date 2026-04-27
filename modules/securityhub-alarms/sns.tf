# AWS CloudWatch doesn't support using the AWS-managed KMS key for publishing things from CloudWatch to SNS
# See: https://aws.amazon.com/premiumsupport/knowledge-center/cloudwatch-receive-sns-for-alarm-trigger/
resource "aws_kms_key" "securityhub-alarms" {
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  description                        = "SecurityHub alarms encryption key"
  enable_key_rotation                = true
  policy                             = data.aws_iam_policy_document.securityhub-alarms-kms.json
  tags                               = var.tags
}

resource "aws_kms_alias" "securityhub-alarms" {
  name          = var.securityhub_alarms_kms_name
  target_key_id = aws_kms_key.securityhub-alarms.id
}

# SecurityHub alarms KMS multi-Region
resource "aws_kms_key" "securityhub_alarms_multi_region" {
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  description                        = "SecurityHub alarms encryption key"
  enable_key_rotation                = true
  policy                             = data.aws_iam_policy_document.securityhub-alarms-kms.json
  tags                               = var.tags
  multi_region                       = true
}

resource "aws_kms_alias" "securityhub_alarms_multi_region" {
  name          = var.securityhub_alarms_multi_region_kms_name
  target_key_id = aws_kms_key.securityhub_alarms_multi_region.id
}

# SNS topic, required for remediation
resource "aws_sns_topic" "securityhub-alarms" {
  name              = var.securityhub_alarms_sns_topic_name
  kms_master_key_id = aws_kms_key.securityhub-alarms.arn
  tags              = var.tags
}

# SNS topic for high-priority rememdiation
resource "aws_sns_topic" "high_priority_alarms_topic" {
  name              = var.high_priority_sns_topic_name
  kms_master_key_id = aws_kms_key.securityhub-alarms.arn
  tags              = var.tags
}

# High Priority PagerDuty Notifications
# This adds pagerduty ingration for alarms alerting to the high-priority slack channel.
module "pagerduty_high_priority_alerts" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-pagerduty-integration?ref=d88bd90d490268896670a898edfaba24bba2f8ab" # v3.0.0
  depends_on = [
    aws_sns_topic.high_priority_alarms_topic
  ]
  sns_topics                = compact([aws_sns_topic.high_priority_alarms_topic.name])
  pagerduty_integration_key = var.high_priority_pagerduty_key
}