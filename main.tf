module "cloudtrail" {
  source = "./modules/cloudtrail"
  tags   = var.tags
}

module "config" {
  source          = "./modules/config"
  tags            = var.tags
  root_account_id = var.root_account_id
  cloudtrail = {
    cloudwatch_log_group_arn = module.cloudtrail.cloudwatch_log_group_arn
    s3_bucket_id             = module.cloudtrail.s3_bucket_id
    sns_topic_arn            = module.cloudtrail.sns_topic_arn
  }
  depends_on = [module.cloudtrail]
}
