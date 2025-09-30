locals {
  regions = ["eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "us-east-1"]
  provider_alias_map = {
    "eu-west-1"    = "aws.eu-west-1"
    "eu-west-2"    = "aws.eu-west-2"
    "eu-west-3"    = "aws.eu-west-3"
    "eu-central-1" = "aws.eu-central-1"
    "us-east-1"    = "aws.us-east-1"
  }
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

provider "aws" {
  alias  = "eu-west-2"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "eu-west-3"
  region = "eu-west-3"
}

provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_west_1" {
  provider      = aws.eu-west-1
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_west_2" {
  provider      = aws.eu-west-2
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_west_3" {
  provider      = aws.eu-west-3
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_central_1" {
  provider      = aws.eu-central-1
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}
resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_us_east_1" {
  provider      = aws.us-east-1
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}