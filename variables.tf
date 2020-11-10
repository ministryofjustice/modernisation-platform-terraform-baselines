variable "root_account_id" {
  type        = string
  description = "The AWS Organisations root account ID that this account should be part of"
}

variable "tags" {
  default     = {}
  description = "Tags to apply to resources, where applicable"
  type        = map
}
