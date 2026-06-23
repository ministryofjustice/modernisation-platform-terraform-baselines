locals {
  enabled           = toset(["enabled"])
  not_enabled       = toset([])
  cloudtrail_bucket = "modernisation-platform-logs-cloudtrail"
  config_bucket     = "modernisation-platform-logs-config"
  workspace_name    = terraform.workspace == "default" ? "modernisation-platform" : terraform.workspace

  securityhub_forwarding_enabled       = var.enable_securityhub_event_forwarding
  securityhub_forwarding_event_bus_arn = var.securityhub_central_event_bus_arn
  securityhub_forwarding_scope         = var.securityhub_forwarding_scope

  session_manager_logging_excluded_by_env_repo_opt_in = anytrue([
    for application in var.session_manager_logging_excluded_applications :
    startswith(local.workspace_name, "${application}-")
  ])

  enable_session_manager_logging = var.enable_session_manager_logging && !local.session_manager_logging_excluded_by_env_repo_opt_in

  session_manager_log_retention_in_days = endswith(local.workspace_name, "-production") ? 400 : 30
}
