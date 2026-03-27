module "iam_credential_response" {
  count  = var.high_priority_pagerduty_integration_key != "" ? 1 : 0
  source = "./modules/iam-credential-response"

  pagerduty_integration_key = var.high_priority_pagerduty_integration_key
}