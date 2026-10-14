# IAM Access Analyzer

Terraform module for enabling [IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html).

## Usage

```terraform
module "access-analyzer" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/access-analyzer"
}
```

### Unused Access Detection (Disabled by Default)

This module supports optional unused IAM access detection. **This feature is disabled by default** and provides detection only—owner notification and removal workflows remain follow-ups.

```terraform
module "access-analyzer" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/access-analyzer"

  enable_unused_access_analyzer = false  # Default: disabled
  unused_access_analyzer_name   = "unused-access-analyzer"
  unused_access_age_days        = 90

  tags = {
    Owner = "security-team"
  }
}
```

**Important considerations:**

- **Region:** Deploy in one approved region per account to avoid duplicate global IAM analysis.
- **Cost:** Unused access analysis incurs additional AWS charges. Review [IAM Access Analyzer pricing](https://aws.amazon.com/iam/access-analyzer/pricing/).
- **Testing:** Prospective test account is `sprinkler-development`.
- **Detection only:** This implementation detects unused roles. Owner tags on IAM roles, owner notification integration, and approved removal/justification workflow are follow-up tasks (see [SIP #120](https://github.com/ministryofjustice/modernisation-platform-security/issues/120)).
- **Review before removal:** Findings must be reviewed before any IAM role removal. Do not delete resources without approval.

## Inputs

| Name                            | Description                                                          | Type   | Default                   | Required |
| ------------------------------- | -------------------------------------------------------------------- | ------ | ------------------------- | -------- |
| tags                            | Tags to apply to resources                                           | map    | {}                        | no       |
| enable_unused_access_analyzer   | Enable ACCOUNT_UNUSED_ACCESS analyzer to detect unused IAM roles     | bool   | false                     | no       |
| unused_access_analyzer_name     | Name for the unused access analyzer                                  | string | "unused-access-analyzer" | no       |
| unused_access_age_days          | Number of days after which access is considered unused (1-365)       | number | 90                        | no       |

## Outputs

| Name                        | Description                                                  |
| --------------------------- | ------------------------------------------------------------ |
| unused_access_analyzer_arn  | ARN of the unused access analyzer (empty string if disabled) |

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
