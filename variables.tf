variable "name_prefix" {
  description = "Prefix to apply to all named resources for identification."
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all taggable resources."
  type        = map(string)
  default     = {}
}

variable "enable_guardduty" {
  description = "Whether to enable Amazon GuardDuty."
  type        = bool
  default     = true
}

variable "guardduty_s3_protection" {
  description = "Whether to enable GuardDuty S3 protection."
  type        = bool
  default     = true
}

variable "guardduty_eks_protection" {
  description = "Whether to enable GuardDuty EKS protection."
  type        = bool
  default     = true
}

variable "guardduty_malware_protection" {
  description = "Whether to enable GuardDuty malware protection for EBS volumes."
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Whether to enable AWS Security Hub."
  type        = bool
  default     = true
}

variable "security_hub_standards" {
  description = "List of Security Hub standard ARN suffixes to enable."
  type        = list(string)
  default = [
    "cis-aws-foundations-benchmark/v/1.4.0",
    "aws-foundational-security-best-practices/v/1.0.0",
  ]
}

variable "enable_config" {
  description = "Whether to enable AWS Config."
  type        = bool
  default     = true
}

variable "config_delivery_s3_bucket" {
  description = "Name of the S3 bucket for AWS Config delivery channel."
  type        = string
  default     = ""
}

variable "config_sns_topic_arn" {
  description = "ARN of the SNS topic for AWS Config notifications."
  type        = string
  default     = ""
}

variable "config_all_supported_resource_types" {
  description = "Whether AWS Config records all supported resource types."
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Whether to enable AWS CloudTrail."
  type        = bool
  default     = true
}

variable "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail log delivery."
  type        = string
  default     = ""
}

variable "cloudtrail_kms_key_arn" {
  description = "ARN of the KMS key for CloudTrail log encryption; if empty a new key is created."
  type        = string
  default     = ""
}

variable "cloudtrail_enable_log_file_validation" {
  description = "Whether to enable CloudTrail log file integrity validation."
  type        = bool
  default     = true
}

variable "cloudtrail_is_multi_region" {
  description = "Whether CloudTrail captures events from all regions."
  type        = bool
  default     = true
}

variable "cloudtrail_include_global_events" {
  description = "Whether CloudTrail includes global service events."
  type        = bool
  default     = true
}

variable "cloudtrail_enable_insights" {
  description = "Whether to enable CloudTrail Insights events."
  type        = bool
  default     = true
}

variable "enable_macie" {
  description = "Whether to enable Amazon Macie."
  type        = bool
  default     = true
}

variable "macie_finding_publishing_frequency" {
  description = "Frequency at which Macie publishes findings (FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS)."
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.macie_finding_publishing_frequency)
    error_message = "Valid values are FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "enable_access_analyzer" {
  description = "Whether to enable IAM Access Analyzer."
  type        = bool
  default     = true
}

variable "access_analyzer_type" {
  description = "Type of IAM Access Analyzer (ACCOUNT or ORGANIZATION)."
  type        = string
  default     = "ACCOUNT"

  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.access_analyzer_type)
    error_message = "Valid values are ACCOUNT or ORGANIZATION."
  }
}

variable "enable_detective" {
  description = "Whether to enable Amazon Detective."
  type        = bool
  default     = false
}

variable "enable_iam_password_policy" {
  description = "Whether to configure the IAM account password policy."
  type        = bool
  default     = true
}

variable "password_policy_min_length" {
  description = "Minimum length for IAM user passwords."
  type        = number
  default     = 14
}

variable "password_policy_require_symbols" {
  description = "Whether IAM user passwords must contain at least one symbol."
  type        = bool
  default     = true
}

variable "password_policy_require_numbers" {
  description = "Whether IAM user passwords must contain at least one number."
  type        = bool
  default     = true
}

variable "password_policy_require_uppercase" {
  description = "Whether IAM user passwords must contain at least one uppercase character."
  type        = bool
  default     = true
}

variable "password_policy_require_lowercase" {
  description = "Whether IAM user passwords must contain at least one lowercase character."
  type        = bool
  default     = true
}

variable "password_policy_max_age" {
  description = "Number of days before an IAM user password expires."
  type        = number
  default     = 90
}

variable "password_policy_reuse_prevention" {
  description = "Number of previous passwords that users are prevented from reusing."
  type        = number
  default     = 24
}

variable "password_policy_allow_users_to_change" {
  description = "Whether IAM users are allowed to change their own passwords."
  type        = bool
  default     = true
}
