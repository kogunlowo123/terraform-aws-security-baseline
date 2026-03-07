variable "name_prefix" {
  description = "Prefix to apply to all named resources."
  type        = string
}

variable "create_break_glass_user" {
  description = "Whether to create the break-glass emergency IAM user."
  type        = bool
  default     = true
}

variable "create_security_audit_role" {
  description = "Whether to create the security audit IAM role."
  type        = bool
  default     = true
}

variable "security_audit_trusted_arns" {
  description = "List of ARNs trusted to assume the security audit role."
  type        = list(string)
  default     = []
}

variable "require_mfa_for_audit_role" {
  description = "Whether to require MFA when assuming the security audit role."
  type        = bool
  default     = true
}

variable "create_support_role" {
  description = "Whether to create the AWS Support access IAM role."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
