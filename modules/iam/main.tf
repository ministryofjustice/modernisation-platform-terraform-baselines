resource "aws_iam_account_password_policy" "default" {
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 90
  minimum_password_length        = 14
  password_reuse_prevention      = 24
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  require_uppercase_characters   = true
}


# Prevent making AMIs publicly accessible in the account.
resource "aws_ec2_image_block_public_access" "block-public-ami" {
  state = "block-new-sharing"
}
