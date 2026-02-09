module "securityhub-ap-northeast-1" {
  for_each = contains(var.enabled_securityhub_regions, "ap-northeast-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-northeast-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-ap-northeast-2" {
  for_each = contains(var.enabled_securityhub_regions, "ap-northeast-2") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-northeast-2
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-ap-south-1" {
  for_each = contains(var.enabled_securityhub_regions, "ap-south-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-south-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-ap-southeast-1" {
  for_each = contains(var.enabled_securityhub_regions, "ap-southeast-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-southeast-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-ap-southeast-2" {
  for_each = contains(var.enabled_securityhub_regions, "ap-southeast-2") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.ap-southeast-2
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-ca-central-1" {
  for_each = contains(var.enabled_securityhub_regions, "ca-central-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.ca-central-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-eu-central-1" {
  for_each = contains(var.enabled_securityhub_regions, "eu-central-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-central-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-eu-north-1" {
  for_each = contains(var.enabled_securityhub_regions, "eu-north-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-north-1
  }
  pagerduty_integration_key       = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope  = var.securityhub_slack_alerts_scope
}

module "securityhub-eu-west-1" {
  for_each = contains(var.enabled_securityhub_regions, "eu-west-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-west-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-eu-west-2" {
  for_each = contains(var.enabled_securityhub_regions, "eu-west-2") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-west-2
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-eu-west-3" {
  for_each = contains(var.enabled_securityhub_regions, "eu-west-3") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.eu-west-3
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn

}

module "securityhub-sa-east-1" {
  for_each = contains(var.enabled_securityhub_regions, "sa-east-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.sa-east-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-us-east-1" {
  for_each = contains(var.enabled_securityhub_regions, "us-east-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.us-east-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-us-east-2" {
  for_each = contains(var.enabled_securityhub_regions, "us-east-2") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.us-east-2
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-us-west-1" {
  for_each = contains(var.enabled_securityhub_regions, "us-west-1") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.us-west-1
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}

module "securityhub-us-west-2" {
  for_each = contains(var.enabled_securityhub_regions, "us-west-2") ? local.enabled : local.not_enabled

  source = "./modules/securityhub"
  providers = {
    aws = aws.us-west-2
  }
  pagerduty_integration_key           = var.securityhub_slack_alerts_pagerduty_integration_key
  enable_securityhub_slack_alerts     = var.enable_securityhub_slack_alerts
  securityhub_slack_alerts_scope      = var.securityhub_slack_alerts_scope
  enable_securityhub_event_forwarding = var.enable_securityhub_event_forwarding
  central_event_bus_arn               = var.securityhub_central_event_bus_arn
}
