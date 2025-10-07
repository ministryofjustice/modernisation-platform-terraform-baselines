resource "aws_ssm_service_setting" "disable_public_sharing" {
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
    lifecycle {
    ignore_changes = [setting_id]
  }
}