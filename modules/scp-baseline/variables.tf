variable "name_prefix" {
  description = "Prefix to apply to all named resources."
  type        = string
}

variable "target_ou_ids" {
  description = "List of AWS Organization OU IDs to attach the SCPs to."
  type        = list(string)
}

variable "enable_deny_root_usage" {
  description = "Whether to create and attach the deny-root-usage SCP."
  type        = bool
  default     = true
}

variable "enable_deny_leaving_org" {
  description = "Whether to create and attach the deny-leaving-org SCP."
  type        = bool
  default     = true
}

variable "enable_require_encryption" {
  description = "Whether to create and attach the require-encryption SCP."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
