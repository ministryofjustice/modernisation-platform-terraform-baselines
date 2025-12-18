output "ebs_snapshot_block_public_access_state" {
  description = "The configured state for EBS snapshot block public access in this region."
  value       = aws_ebs_snapshot_block_public_access.this.state
}