data "aws_caller_identity" "current" {}

module "cloudtrail-test" {
  depends_on                       = [aws_s3_bucket_policy.s3_cloudtrail_policy]
  source                           = "../../modules/cloudtrail"
  cloudtrail_name                  = var.cloudtrail_name
  cloudtrail_policy_name           = var.cloudtrail_policy_name
  cloudtrail_kms_key               = aws_kms_key.cloudtrail_kms_key.arn
  cloudtrail_bucket                = aws_s3_bucket.cloudtrail_s3_bucket.id
  enable_cloudtrail_s3_mgmt_events = var.enable_cloudtrail_s3_mgmt_events
}

# Cloudtrail KMS
resource "aws_kms_key" "cloudtrail_kms_key" {
  deletion_window_in_days = 7
  description             = "Cloudtrail encryption key"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudtrail_kms.json
}

resource "aws_kms_alias" "cloudtrail_kms_alias" {
  name          = var.aws_kms_alias_name
  target_key_id = aws_kms_key.cloudtrail_kms_key.id
}

data "aws_iam_policy_document" "cloudtrail_kms" {

  #checkov:skip=CKV_AWS_356: ""
  #checkov:skip=CKV_AWS_111: "Ensure IAM policies does not allow write access without constraints"
  #checkov:skip=CKV_AWS_109: "Ensure IAM policies does not allow permissions management / resource exposure without constraints - This is applied to a specific SNS topic"

  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.environment_management.account_ids["testing-test"]}:root"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

     principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
        effect    = "Allow"
        actions    = [
          "kms:*"
        ]
        resources = ["*"]

        principals {
          type    = "Service"
          identifiers = ["logs.eu-west-2.amazonaws.com"]
        }
  }
}