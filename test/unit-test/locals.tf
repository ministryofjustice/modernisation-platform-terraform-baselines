data "aws_secretsmanager_secret" "baseline_integration_keys" {
  provider = aws.testing-ci-user
  arn      = format("arn:aws:secretsmanager:eu-west-2:%s:secret:baseline_integration_keys-26WzqG", local.environment_management["modernisation_platform_account_id"])
}

data "aws_secretsmanager_secret_version" "baseline_integration_keys" {
  provider  = aws.testing-ci-user
  secret_id = data.aws_secretsmanager_secret.baseline_integration_keys.id
}

data "aws_ssm_parameter" "environment_management_arn" {
  provider = aws.testing-ci-user
  name     = "environment_management_arn"
}

data "aws_secretsmanager_secret" "environment_management" {
  provider = aws.testing-ci-user
  arn      = data.aws_ssm_parameter.environment_management_arn.value
}

# Get latest secret value with ID from above. This secret stores account IDs for the Modernisation Platform sub-accounts
data "aws_secretsmanager_secret_version" "environment_management" {
  provider  = aws.testing-ci-user
  secret_id = data.aws_secretsmanager_secret.environment_management.id
}

locals {

  application_name = "testing"

  environment_management = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production    = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"
  is-preproduction = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction"
  is-test          = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-test"
  is-development   = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-development"

  # Merge tags from the environment json file with additional ones
  tags = merge(
    jsondecode(data.http.environments_file.response_body).tags,
    { "is-production" = local.is-production },
    { "environment-name" = terraform.workspace },
    { "source-code" = "https://github.com/ministryofjustice/modernisation-platform" }
  )

  environment = trimprefix(terraform.workspace, "${var.networking[0].application}-")
  vpc_name    = var.networking[0].business-unit
  subnet_set  = var.networking[0].set

  is_live       = [substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production" || substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-preproduction" ? "live" : "non-live"]
  provider_name = "core-vpc-${local.environment}"
}
