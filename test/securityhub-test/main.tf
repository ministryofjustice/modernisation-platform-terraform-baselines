module "securityhub-test" {
  source                       = "../../modules/securityhub"
  sechub_eventbridge_rule_name = var.sechub_eventbridge_rule_name
  sechub_sns_topic_name        = var.sechub_sns_topic_name
  sechub_sns_kms_key_name      = var.sechub_sns_kms_key_name
}