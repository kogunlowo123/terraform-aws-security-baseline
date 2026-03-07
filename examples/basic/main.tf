provider "aws" {
  region = "us-east-1"
}

module "security_baseline" {
  source = "../../"

  name_prefix = "myapp"

  # GuardDuty
  enable_guardduty             = true
  guardduty_s3_protection      = true
  guardduty_eks_protection     = false
  guardduty_malware_protection = true

  # Security Hub
  enable_security_hub = true
  security_hub_standards = [
    "aws-foundational-security-best-practices/v/1.0.0",
  ]

  # AWS Config
  enable_config             = true
  config_delivery_s3_bucket = "myapp-config-bucket"

  # CloudTrail
  enable_cloudtrail         = true
  cloudtrail_s3_bucket_name = "myapp-cloudtrail-bucket"

  # Macie
  enable_macie = true

  # Access Analyzer
  enable_access_analyzer = true
  access_analyzer_type   = "ACCOUNT"

  # Detective (disabled by default)
  enable_detective = false

  # IAM Password Policy
  enable_iam_password_policy = true

  tags = {
    Project     = "security-baseline"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

output "guardduty_detector_id" {
  value = module.security_baseline.guardduty_detector_id
}

output "cloudtrail_arn" {
  value = module.security_baseline.cloudtrail_arn
}
