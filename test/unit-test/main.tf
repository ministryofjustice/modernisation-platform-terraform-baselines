resource "aws_sns_topic" "test_alarms" {
  #checkov:skip=CKV_AWS_26:"encrypted topics do not work with pagerduty subscription"
  name = "test_alarms"
}

module "test_alerts" {
  source             = "../../modules/coudtrail"
  cloudtrail_kms_key = var.cloudtrail_kms_key
  cloudtrail_bucket  = var.cloudtrail_bucket
  root_account_id    = var.root_account_id
  # sns_topics                = [aws_sns_topic.test_alarms.name]
  # baseline_integration_key  = local.baseline_integration_keys["test_alarms"]
  depends_on = [aws_sns_topic.test_alarms]
}

