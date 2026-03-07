variable "name_prefix" {
  description = "Prefix to apply to all named resources."
  type        = string
}

variable "finding_publishing_frequency" {
  description = "Frequency at which GuardDuty publishes findings."
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "auto_enable_organization_members" {
  description = "Auto-enable for organization members (ALL, NEW, NONE)."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "NEW", "NONE"], var.auto_enable_organization_members)
    error_message = "Valid values are ALL, NEW, or NONE."
  }
}

variable "enable_s3_protection" {
  description = "Whether to enable S3 protection."
  type        = bool
  default     = true
}

variable "enable_eks_protection" {
  description = "Whether to enable EKS audit log monitoring."
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Whether to enable malware protection for EBS volumes."
  type        = bool
  default     = true
}

variable "member_accounts" {
  description = "List of member accounts to add to GuardDuty."
  type = list(object({
    account_id = string
    email      = string
  }))
  default = []
}

variable "publishing_destination_bucket_arn" {
  description = "ARN of the S3 bucket for publishing GuardDuty findings."
  type        = string
  default     = ""
}

variable "publishing_destination_kms_key_arn" {
  description = "ARN of the KMS key for encrypting published findings."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
