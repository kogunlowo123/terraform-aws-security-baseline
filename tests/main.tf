module "test" {
  source = "../"

  name_prefix = "test-security"

  tags = {
    Project     = "security-baseline-test"
    Environment = "test"
  }

  # GuardDuty
  enable_guardduty             = true
  guardduty_s3_protection      = true
  guardduty_eks_protection     = true
  guardduty_malware_protection = true

  # Security Hub
  enable_security_hub = true
  security_hub_standards = [
    "cis-aws-foundations-benchmark/v/1.4.0",
    "aws-foundational-security-best-practices/v/1.0.0",
  ]

  # AWS Config
  enable_config                       = true
  config_all_supported_resource_types = true

  # CloudTrail
  enable_cloudtrail                       = true
  cloudtrail_enable_log_file_validation   = true
  cloudtrail_is_multi_region              = true
  cloudtrail_include_global_events        = true
  cloudtrail_enable_insights              = true

  # Macie
  enable_macie                        = true
  macie_finding_publishing_frequency  = "FIFTEEN_MINUTES"

  # IAM Access Analyzer
  enable_access_analyzer = true
  access_analyzer_type   = "ACCOUNT"

  # Detective (disabled for basic test)
  enable_detective = false

  # IAM Password Policy
  enable_iam_password_policy       = true
  password_policy_min_length       = 14
  password_policy_require_symbols  = true
  password_policy_require_numbers  = true
  password_policy_require_uppercase = true
  password_policy_require_lowercase = true
  password_policy_max_age          = 90
  password_policy_reuse_prevention = 24
}
