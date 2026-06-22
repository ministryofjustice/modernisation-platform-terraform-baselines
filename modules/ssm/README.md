# Systems Manager baseline

Terraform module for baseline Systems Manager controls:

- Disabling [public sharing of SSM documents](https://docs.aws.amazon.com/systems-manager/latest/userguide/documents-ssm-sharing.html).
- Enabling Session Manager transcript logging to CloudWatch Logs when configured.
- Creating the supporting IAM policy for EC2 instance roles to write transcript logs when configured.

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
| create_session_manager_logging_iam_policy | Create the IAM policy that allows EC2 instance roles to write Session Manager transcript logs. Only enable once per account. | bool | false | no |
| enable_session_manager_logging          | Enable Session Manager transcript logging to CloudWatch Logs.                 | bool        | false   | no       |
| session_manager_idle_timeout_minutes    | Idle timeout in minutes for Session Manager shell sessions.                   | number      | 60      | no       |
| session_manager_log_kms_key_id          | Optional KMS key ARN or ID used to encrypt the CloudWatch log group.          | string      | null    | no       |
| session_manager_log_retention_in_days   | Retention period in days for Session Manager transcript logs.                 | number      | 400     | no       |
| session_manager_logging_regions         | Regions where Session Manager transcript log groups are created. Used to scope the supporting IAM policy. | set(string) | ["eu-west-1", "eu-west-2"] | no |
| tags                                    | Tags to apply to resources that support tagging.                              | map(any)    | {}      | no       |

## Outputs

| Name | Description |
| ---- | ----------- |
| session_manager_cloudwatch_logs_policy_arn | ARN of the IAM policy that allows EC2 instance roles to write Session Manager transcript logs to CloudWatch Logs. |

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
