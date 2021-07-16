data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "cloudtrail" {
  source = "./modules/cloudtrail"
  providers = {
    aws.replication-region = aws.replication-region
  }
  replication_role_arn = module.s3-replication-role.role.arn
  tags                 = var.tags
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

  depends_on = [module.cloudtrail]

  tags = var.tags
}

module "s3-replication-role" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-s3-bucket-replication-role?ref=v1.0.0"
  buckets = [
    module.config-bucket.bucket.arn,
    module.cloudtrail.s3_bucket.arn,
    module.cloudtrail.log_bucket.arn
  ]
  tags = var.tags
}
