module "cloudtrail" {
  source = "./modules/cloudtrail"
  tags   = var.tags
}

module "iam" {
  source = "./modules/iam"
}

module "support" {
  source = "./modules/support"
  tags   = var.tags
}

module "securityhub-alarms" {
  source = "./modules/securityhub-alarms"
  tags   = var.tags
}
