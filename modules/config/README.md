# AWS Config

Terraform module for enabling [AWS Config](https://aws.amazon.com/config/) and some [rules](RULES.md).

## Usage

```
module "config" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/config"
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cloudtrail | CloudTrail variables for: SNS topic, AWS S3 bucket, and CloudWatch Log Group to configure the Config rule to check it's configured correctly | map | | yes |
| root_account_id | The AWS Organisations root account ID that this account should be part of | string | | yes |
| iam_role_arn | IAM role ARN for the AWS Config service role | string | | yes |
| s3_bucket_id | S3 bucket ID for AWS Config to publish to | string | | yes |
| home_region | Region to enable AWS Config rules for global resources, such as IAM. Currently taken from the calling region | string | | yes |
| tags | Tags to apply to resources | map | {} | no |

## Outputs
| Name | Description | Sensitive |
|------|-------------|-----------|
| sns_topic_arn | SNS topic ARN that AWS Config publishes to | no |

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
