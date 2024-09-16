# AWS provider for the workspace you're working in (every resource will default to using this, unless otherwise specified)
provider "aws" {
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:role/MemberInfrastructureAccess"
  }
}

# AWS provider for the testing-ci user (testing-test account), to get things from there if required
provider "aws" {
  alias  = "testing-ci-user"
  region = "eu-west-2"
}