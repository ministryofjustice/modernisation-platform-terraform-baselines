# Systems Manager baseline

Terraform module for baseline Systems Manager controls:

- Disabling [public sharing of SSM documents](https://docs.aws.amazon.com/systems-manager/latest/userguide/documents-ssm-sharing.html).
- Enabling Session Manager transcript logging to CloudWatch Logs when configured.

## Usage

```
module "ssm" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/ssm"

  enable_session_manager_logging = true
}

```

## Inputs

| Name                                    | Description                                                                  | Type        | Default | Required |
| --------------------------------------- | ---------------------------------------------------------------------------- | ----------- | ------- | -------- |
| enable_session_manager_logging          | Enable Session Manager transcript logging to CloudWatch Logs.                 | bool        | false   | no       |
| session_manager_idle_timeout_minutes    | Idle timeout in minutes for Session Manager shell sessions.                   | number      | 60      | no       |
| session_manager_log_kms_key_id          | Optional KMS key ARN or ID used to encrypt the CloudWatch log group.          | string      | null    | no       |
| session_manager_log_retention_in_days   | Retention period in days for Session Manager transcript logs.                 | number      | 400     | no       |
| tags                                    | Tags to apply to resources that support tagging.                              | map(any)    | {}      | no       |

## Outputs
None.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
