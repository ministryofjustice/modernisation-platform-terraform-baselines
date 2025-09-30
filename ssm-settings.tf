locals {
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}

# One resource per alias 
resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_west_1" {
  provider      = aws.eu-west-1
  setting_id    = local.setting_id
  setting_value = local.setting_value
  lifecycle {
    ignore_changes = [setting_id]
  }
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_west_2" {
  provider      = aws.eu-west-2
  setting_id    = local.setting_id
  setting_value = local.setting_value
  lifecycle {
    ignore_changes = [setting_id]
  }
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_west_3" {
  provider      = aws.eu-west-3
  setting_id    = local.setting_id
  setting_value = local.setting_value
  lifecycle {
    ignore_changes = [setting_id]
  }
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_eu_central_1" {
  provider      = aws.eu-central-1
  setting_id    = local.setting_id
  setting_value = local.setting_value
  lifecycle {
    ignore_changes = [setting_id]
  }
}

resource "aws_ssm_service_setting" "block_ssm_doc_public_sharing_us_east_1" {
  provider      = aws.us-east-1
  setting_id    = local.setting_id
  setting_value = local.setting_value
  lifecycle {
    ignore_changes = [setting_id]
  }
}