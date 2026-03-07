provider "aws" {
  region = "us-east-1"
}

################################################################################
# Security Baseline - Full Enterprise Configuration
################################################################################

module "security_baseline" {
  source = "../../"

  name_prefix = "enterprise"

  # GuardDuty - all protections enabled
  enable_guardduty             = true
  guardduty_s3_protection      = true
  guardduty_eks_protection     = true
  guardduty_malware_protection = true

  # Security Hub - CIS and FSBP standards
  enable_security_hub = true
  security_hub_standards = [
    "cis-aws-foundations-benchmark/v/1.4.0",
    "aws-foundational-security-best-practices/v/1.0.0",
  ]

  # AWS Config - full recording
  enable_config                       = true
  config_delivery_s3_bucket           = "enterprise-config-${data.aws_caller_identity.current.account_id}"
  config_sns_topic_arn                = aws_sns_topic.config_notifications.arn
  config_all_supported_resource_types = true

  # CloudTrail - multi-region with insights
  enable_cloudtrail                     = true
  cloudtrail_s3_bucket_name             = "enterprise-cloudtrail-${data.aws_caller_identity.current.account_id}"
  cloudtrail_enable_log_file_validation = true
  cloudtrail_is_multi_region            = true
  cloudtrail_include_global_events      = true
  cloudtrail_enable_insights            = true

  # Macie
  enable_macie                       = true
  macie_finding_publishing_frequency = "FIFTEEN_MINUTES"

  # Access Analyzer
  enable_access_analyzer = true
  access_analyzer_type   = "ORGANIZATION"

  # Detective
  enable_detective = true

  # IAM Password Policy - CIS-compliant
  enable_iam_password_policy         = true
  password_policy_min_length         = 14
  password_policy_require_symbols    = true
  password_policy_require_numbers    = true
  password_policy_require_uppercase  = true
  password_policy_require_lowercase  = true
  password_policy_max_age            = 90
  password_policy_reuse_prevention   = 24

  tags = {
    Project       = "security-baseline"
    Environment   = "production"
    ManagedBy     = "terraform"
    Compliance    = "cis-1.4"
    CostCenter    = "security"
  }
}

################################################################################
# IAM Baseline
################################################################################

module "iam_baseline" {
  source = "../../modules/iam-baseline"

  name_prefix = "enterprise"

  create_break_glass_user    = true
  create_security_audit_role = true
  create_support_role        = true

  security_audit_trusted_arns = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
  ]

  tags = {
    Project     = "security-baseline"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

################################################################################
# Supporting Resources
################################################################################

data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "config_notifications" {
  name = "enterprise-config-notifications"

  tags = {
    Project     = "security-baseline"
    Environment = "production"
  }
}

################################################################################
# Outputs
################################################################################

output "guardduty_detector_id" {
  value = module.security_baseline.guardduty_detector_id
}

output "securityhub_account_arn" {
  value = module.security_baseline.securityhub_account_arn
}

output "cloudtrail_arn" {
  value = module.security_baseline.cloudtrail_arn
}

output "cloudtrail_kms_key_arn" {
  value = module.security_baseline.cloudtrail_kms_key_arn
}

output "access_analyzer_arn" {
  value = module.security_baseline.access_analyzer_arn
}

output "detective_graph_arn" {
  value = module.security_baseline.detective_graph_arn
}

output "break_glass_user_arn" {
  value = module.iam_baseline.break_glass_user_arn
}

output "security_audit_role_arn" {
  value = module.iam_baseline.security_audit_role_arn
}
