module "cloudtrail" {
  source = "./modules/cloudtrail"
  tags   = var.tags
}

module "iam" {
  source = "./modules/iam"
}
