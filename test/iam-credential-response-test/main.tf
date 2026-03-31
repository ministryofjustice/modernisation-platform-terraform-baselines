module "iam-credential-response-test" {
  source = "../../modules/iam-credential-response"

  pagerduty_integration_key        = var.pagerduty_integration_key
  credential_responder_role_name   = var.credential_responder_role_name
  credential_responder_lambda_name = var.credential_responder_lambda_name
}
