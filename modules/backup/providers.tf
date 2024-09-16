# Replica region for kms key
provider "aws" {
  alias  = "modernisation-platform-eu-west-1"
  region = "eu-west-1"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:role/MemberInfrastructureAccess"
  }

}