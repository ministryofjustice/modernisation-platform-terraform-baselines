resource "aws_ssm_service_setting" "disable_public_sharing" {
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"

  lifecycle {
    prevent_destroy = true
    ignore_changes = [setting_id]
  }
}
