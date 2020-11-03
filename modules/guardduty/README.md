# GuardDuty

Terraform module for enabling [GuardDuty](https://aws.amazon.com/guardduty/).

## Usage

```
module "guardduty" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/guardduty"
}
```

## Inputs
| Name | Description                | Type | Default | Required |
|------|----------------------------|------|---------|----------|
| tags | Tags to apply to resources | map  | {}      | no       |

## Outputs
None.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).
