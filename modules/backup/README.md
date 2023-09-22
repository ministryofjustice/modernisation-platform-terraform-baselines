# AWS Backup

Terraform module for configuring [AWS Backup](https://aws.amazon.com/backup/).

## Backup Vault
This module creates a new vault, named `everything`, in which the backup plans use as a destination.

## Backup Plans
This module creates two backup plans:
- `backup-daily-retain-30-days` plans daily backups, which are deleted every 30 days. The backups start at 0:30 and must finish within 6 hours of starting.
- `backup-daily-cold-storage-monthly-retain-30-days` plans daily backups, which are deleted every 30 days. As above, the backups start at 0:30 and must finish within 6 hours of starting.

## Backup Selections
This module selects resources with the following tag/key values to backup using the above plan. Resources can be exluded by setting `skip-backup` to `true`.
- `is-production`: `true`
- `skip-backup`: `!true`

Non-production environments can also make use of backup plans with the following tag/key values:
- `backup`: `true`
- `is-production`: `!true`

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
