variable "replication_role_arn" {
  type        = string
  description = "Role ARN for S3 replication"
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map
}
