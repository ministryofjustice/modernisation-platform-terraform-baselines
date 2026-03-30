module "iam-credential-response-test" {
  source = "../../modules/iam-credential-response"

  pagerduty_integration_key = var.pagerduty_integration_key
}