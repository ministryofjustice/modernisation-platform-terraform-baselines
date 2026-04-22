# AWS Backup

Terraform module for configuring [AWS Backup](https://aws.amazon.com/backup/).

## Backup Vault
This module creates a new vault, named `everything`, in which the backup plans use as a destination.

## Backup Plans
This module creates four backup plans (default names shown):
- `backup-daily-production-retain-30-days` — production warm backups; retention from `prod_backup_retention_days` (default 30 days). Daily at 0:30 UTC, finish within 6 hours of starting.
- `backup-daily-production-cold-storage-90-days` — production cold-storage backups; 90-day retention. Daily at 1:30 UTC, same start and completion windows.
- `backup-daily-non-production-retain-30-days` — non-production warm backups; retention from `non_prod_backup_retention_days` or 7 days when `reduced_preprod_backup_retention` is true. Daily at 0:30 UTC, same windows.
- `backup-daily-non-production-cold-storage-90-days` — non-production cold-storage backups; 90-day retention. Daily at 2:30 UTC, same windows.

## Backup Selections

Selections use `resources = ["*"]` with tag **conditions** (see `main.tf`). Summaries below use the same logic as AWS Backup.

### Production (warm and cold are mutually exclusive)

Every condition in the block must match.

| Plan | `is-production` | `backup` | `backup-cold-storage` |
|------|-----------------|----------|------------------------|
| Warm (`production`) | `true` | not `false` | absent or not `true` |
| Cold (`production_cold_storage`) | `true` | not `false` | `true` |

Set `backup` = `false` to exclude a resource from **both** production plans.

### Non-production (warm and cold are mutually exclusive)

Uses the same **`backup-cold-storage`** opt-in tag as production.

| Plan | `is-production` | `backup` | `backup-cold-storage` |
|------|-----------------|----------|------------------------|
| Warm (`non_production`) | not `true` | `true` | absent or not `true` |
| Cold (`non_production_cold_storage`) | not `true` | `true` | `true` |

Set `backup` = `false` to exclude a resource from both non-production plans.

## Usage

```hcl
module "backup" {
  source       = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/backup"
  iam_role_arn                     = aws_iam_role.backup.arn
  reduced_preprod_backup_retention = var.reduced_preprod_backup_retention
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `iam_role_arn` | IAM role ARN for the AWS Backup service role used by selections. | `string` | — | yes |
| `reduced_preprod_backup_retention` | If `true`, non-production warm plan uses 7-day retention instead of `non_prod_backup_retention_days`. | `bool` | — | yes |
| `tags` | Tags applied to supported resources. | `map(any)` | `{}` | no |
| `sns_backup_topic_key` | Declared for SNS/KMS compatibility; not referenced by resources in this module. | `string` | `alias/aws/sns` | no |
| `aws_backup_vault_name` | Backup vault name. | `string` | `everything` | no |
| `production_backup_plan_name` | Display name of the warm production plan. | `string` | `backup-daily-production-retain-30-days` | no |
| `production_backup_selection_name` | Selection name for the warm production plan. | `string` | `is-production-true` | no |
| `prod_backup_retention_days` | Warm production lifecycle `delete_after` (days). | `number` | `30` | no |
| `non_production_backup_plan_name` | Display name of the warm non-production plan. | `string` | `backup-daily-non-production-retain-30-days` | no |
| `non_production_backup_selection_name` | Selection name for the warm non-production plan. | `string` | `non-production-backup` | no |
| `production_cold_storage_backup_plan_name` | Display name of the cold production plan. | `string` | `backup-daily-production-cold-storage-90-days` | no |
| `production_cold_storage_backup_selection_name` | Selection name for the cold production plan. | `string` | `is-production-true-cold-storage-90-days` | no |
| `non_production_cold_storage_backup_plan_name` | Display name of the cold non-production plan. | `string` | `backup-daily-non-production-cold-storage-90-days` | no |
| `non_production_cold_storage_backup_selection_name` | Selection name for the cold non-production plan. | `string` | `non-production-backup-cold-storage-90-days` | no |
| `backup_aws_sns_topic_name` | SNS topic name for backup job failures. | `string` | `backup_failure_topic` | no |
| `non_prod_backup_retention_days` | Warm non-production `delete_after` when `reduced_preprod_backup_retention` is `false`. | `number` | `30` | no |
| `backup_vault_lock_sns_topic_name` | SNS topic name for vault lock notifications. | `string` | `backup_vault_failure_topic` | no |
| `max_vault_retention_days` | Vault lock maximum retention (days); must be ≥ cold plan `delete_after`. | `number` | `90` | no |
| `min_vault_retention_days` | Vault lock minimum retention (days). | `number` | `7` | no |
| `aws_kms_alias_name` | KMS alias for the multi-Region backup alarms key. | `string` | `alias/backup-alarms-key-multi-region` | no |

## Outputs

| Name | Description |
|------|-------------|
| `aws_backup_vault_arn` | ARN of the backup vault. |
| `aws_backup_plan_production` | ARN of the warm production backup plan. |
| `aws_backup_plan_non_production` | ARN of the warm non-production backup plan. |
| `aws_backup_plan_production_cold_storage` | ARN of the cold production backup plan. |
| `aws_backup_plan_non_production_cold_storage` | ARN of the cold non-production backup plan. |
| `aws_backup_selection_production` | ID of the warm production selection. |
| `aws_backup_selection_non_production` | ID of the warm non-production selection. |
| `aws_backup_selection_production_cold_storage` | ID of the cold production selection. |
| `aws_backup_selection_non_production_cold_storage` | ID of the cold non-production selection. |
| `backup_aws_sns_topic_arn` | ARN of the backup failure SNS topic. |
| `aws_backup_plan_non_production_rule` | Rule block of the warm non-production plan (for inspection/tests). |
| `backup_vault_lock_sns_topic_arn` | ARN of the vault lock SNS topic. |

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
