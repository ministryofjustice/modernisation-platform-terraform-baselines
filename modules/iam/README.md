# IAM Password Policy

Terraform module for creating an IAM Password Policy that complies with the CIS AWS Foundations Benchmark v1.2.0 rules, which are:

- [x] [CIS 1.5 – Ensure IAM password policy requires at least one uppercase letter](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.5-remediation)
- [x] [CIS 1.6 – Ensure IAM password policy requires at least one lowercase letter](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.6-remediation)
- [x] [CIS 1.7 - Ensure IAM password policy requires at least one symbol](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.7-remediation)
- [x] [CIS 1.8 - Ensure IAM password policy requires at least one number](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.8-remediation)
- [x] [CIS 1.9 - Ensure IAM password policy requires a minimum length of 14 or greater](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.9-remediation)
- [x] [CIS 1.10 - Ensure IAM password policy prevents password reuse](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.10-remediation)
- [x] [CIS 1.11 - Ensure IAM password policy expires passwords within 90 days or less](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.11-remediation)

## Usage

```
module "iam" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/iam"
}
```

## Inputs
None.

## Outputs
None.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
