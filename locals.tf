locals {
  enabled           = toset(["enabled"])
  not_enabled       = toset([])
  cloudtrail_bucket = "modernisation-platform-logs-cloudtrail"
  config_bucket     = "modernisation-platform-logs-config"
  workspace_name    = terraform.workspace == "default" ? "modernisation-platform" : terraform.workspace

  securityhub_forwarding_enabled       = var.enable_securityhub_event_forwarding
  securityhub_forwarding_event_bus_arn = var.securityhub_central_event_bus_arn
  securityhub_forwarding_scope         = var.securityhub_forwarding_scope
}
