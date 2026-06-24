resource "aws_ssm_service_setting" "disable_public_sharing" {
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [setting_id]
  }
}

resource "aws_cloudwatch_log_group" "session_manager" {
  count = var.enable_session_manager_logging ? 1 : 0

  name              = "session-manager-logs"
  retention_in_days = var.session_manager_log_retention_in_days
  kms_key_id        = var.session_manager_log_kms_key_id
  tags              = var.tags

  lifecycle {
    prevent_destroy = true
  }
}
