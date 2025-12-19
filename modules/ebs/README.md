# EBS Default Encryption and Snapshot Public Access

Terraform module for enabling secure default EBS settings at the AWS account level, including:

- [EBS Encryption by default](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSEncryption.html#encryption-by-default)
- [Blocking public sharing of EBS snapshots (block all sharing)](https://docs.aws.amazon.com/ebs/latest/userguide/block-public-access-snapshots.html)

## Usage

module "ebs" {
source = "github.com/ministryofjustice/modernisation-platform-terraform-baselines//modules/ebs"
}

## Inputs
None.

## Outputs
None.

## Notes

- These settings are applied at the AWS account level.
- Blocking snapshot public sharing helps prevent accidental data exposure.

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).