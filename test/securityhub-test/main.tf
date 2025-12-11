module "securityhub-test" {
  source                          = "../../modules/securityhub"
  sechub_eventbridge_rule_name    = var.sechub_eventbridge_rule_name
  sechub_sns_topic_name           = var.sechub_sns_topic_name
  sechub_sns_kms_key_name         = var.sechub_sns_kms_key_name
  enable_securityhub_slack_alerts = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope  = var.securityhub_slack_alerts_scope
  pagerduty_integration_key       = var.pagerduty_integration_key
  tags                            = var.tags
}