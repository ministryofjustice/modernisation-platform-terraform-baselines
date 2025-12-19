resource "aws_ebs_encryption_by_default" "default" {
  enabled = true
}

resource "aws_ebs_snapshot_block_public_access" "this" {
  state = "block-all-sharing"
}