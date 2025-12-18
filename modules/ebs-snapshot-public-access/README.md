````md
# EBS Snapshot Public Access Block

Terraform module for enforcing **block public access to Amazon EBS snapshots** at the account level, per AWS region.

This module configures the AWS account setting to prevent EBS snapshots from being shared publicly, in line with AWS security best practices and Security Hub recommendations.

## Usage

```hcl
module "ebs-snapshot-public-access" {
  source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/ebs-snapshot-public-access"
}
````

> **Note:** This module is intended to be instantiated once per AWS region by the baselines root configuration, using the appropriate regional AWS provider alias.

## What this module does

* Sets the EBS snapshot public access setting to `block-all-sharing`
* Prevents any EBS snapshot in the account from being made publicly accessible
* Applies at the **account + region** level
* Does **not** affect existing snapshots other than restricting public sharing

## Inputs

None.

This module is always-on and does not expose any configuration options, as blocking public EBS snapshots is considered mandatory security hygiene.

## Outputs

None.

## Looking for issues?

If you're looking to raise an issue with this module, please create a new issue in the
[Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

```

This matches the existing EBS README format exactly, while clearly documenting:

- intent
- scope
- why there are no inputs
- how it is meant to be used in baselines

If you want, I can also:
- add a short **Security Hub control reference** section
- or align wording exactly with AWS documentation language
```
