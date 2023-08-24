# AWS Backup

Terraform module for configuring [AWS Backup](https://aws.amazon.com/backup/).

## Backup Vault
This module creates a new vault, named `everything`, in which the backup plans use as a destination.

## Backup Plans
This module creates backup plans:
- `backup-daily-monthly-retain-30-days` plans daily backups, which are removed after 30 days. The backups start from 00:30am and must finish within 6 hours of starting.

## Backup Selections
This module selects resources with the following tag key values to backup using the above plan, automatically:
- `is-production`: `true`

## Usage

```
module "backup" {
  source       = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/backup"
  iam_role_arn = ""
}
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| iam_role_arn | IAM role ARN for the AWS Backup service role | string | | yes |
| tags | Tags to apply to resources | map  | {} | no |

## Outputs
None.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
