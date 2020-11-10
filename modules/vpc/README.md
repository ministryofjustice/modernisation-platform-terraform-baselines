# VPC Flow Logs

Terraform module for enabling [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html) and configuring tags on default VPC resources.

## Usage

```
module "vpc" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/vpc"
}
```

## Inputs
| Name | Description                | Type | Default | Required |
|------|----------------------------|------|---------|----------|
| iam_role_arn | IAM role ARN for VPC Flow Logs | string | | yes |
| tags | Tags to apply to resources | map  | {}      | no       |

## Outputs
None.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
