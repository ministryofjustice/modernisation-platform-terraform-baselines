data "aws_kms_key" "cloudtrail_key" {
  provider = aws.testing-ci-user
  key_id   = "alias/testing-ci-user-access-key"
}

module "baselines" {
  source = "../../"
  providers = {
    aws                    = aws
    aws.replication-region = aws.eu-west-2 # Region to replicate S3 buckets into
    aws.ap-northeast-1     = aws.ap-northeast-1
    aws.ap-northeast-2     = aws.ap-northeast-2
    aws.ap-south-1         = aws.ap-south-1
    aws.ap-southeast-1     = aws.ap-southeast-1
    aws.ap-southeast-2     = aws.ap-southeast-2
    aws.ca-central-1       = aws.ca-central-1
    aws.eu-central-1       = aws.eu-central-1
    aws.eu-north-1         = aws.eu-north-1
    aws.eu-west-1          = aws.eu-west-1
    aws.eu-west-2          = aws.eu-west-2
    aws.eu-west-3          = aws.eu-west-3
    aws.sa-east-1          = aws.sa-east-1
    aws.us-east-1          = aws.us-east-1
    aws.us-east-2          = aws.us-east-2
    aws.us-west-1          = aws.us-west-1
    aws.us-west-2          = aws.us-west-2
  }

  # Enable IAM Access Analyzer in eu-west-2
  enabled_access_analyzer_regions = ["eu-west-2"]

  root_account_id = local.root_account_id
  tags            = local.tags

  cloudtrail_kms_key = data.aws_kms_key.cloudtrail_key.arn
}
