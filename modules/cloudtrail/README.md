# CloudTrail

Terraform module for enabling a multi-region [CloudTrail](https://docs.aws.amazon.com/cloudtrail/) trail.

## Usage

```
module "cloudtrail" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/cloudtrail"
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| replication_role_arn | Role ARN for S3 replication | string | | yes |
| tags | Tags to apply to resources | map | {} | no |

## Outputs
| Name | Description | Sensitive |
|------|-------------|-----------|
| cloudwatch_log_group_arn | CloudWatch Log Group ARN for that CloudTrail publishes to | no |
| log_bucket | S3 bucket resource attributes for the S3 server-access logging bucket | no |
| s3_bucket | S3 bucket resource attributes for the CloudTrail S3 bucket | no |
| sns_topic_arn | SNS topic that CloudTrail publishes to | no |

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
