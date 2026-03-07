data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition

  cloudtrail_kms_key_arn = var.cloudtrail_kms_key_arn != "" ? var.cloudtrail_kms_key_arn : try(aws_kms_key.cloudtrail[0].arn, "")
}

################################################################################
# GuardDuty
################################################################################

resource "aws_guardduty_detector" "this" {
  count = var.enable_guardduty ? 1 : 0

  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"

  datasources {
    s3_logs {
      enable = var.guardduty_s3_protection
    }

    kubernetes {
      audit_logs {
        enable = var.guardduty_eks_protection
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.guardduty_malware_protection
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-guardduty"
  })
}

################################################################################
# Security Hub
################################################################################

resource "aws_securityhub_account" "this" {
  count = var.enable_security_hub ? 1 : 0

  enable_default_standards = false
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each = var.enable_security_hub ? toset(var.security_hub_standards) : toset([])

  standards_arn = "arn:${local.partition}:securityhub:${local.region}::standards/${each.value}"

  depends_on = [aws_securityhub_account.this]
}

################################################################################
# AWS Config
################################################################################

resource "aws_config_configuration_recorder" "this" {
  count = var.enable_config ? 1 : 0

  name     = "${var.name_prefix}-config-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = var.config_all_supported_resource_types
    include_global_resource_types = var.config_all_supported_resource_types
  }
}

resource "aws_config_delivery_channel" "this" {
  count = var.enable_config ? 1 : 0

  name           = "${var.name_prefix}-config-delivery"
  s3_bucket_name = var.config_delivery_s3_bucket
  sns_topic_arn  = var.config_sns_topic_arn != "" ? var.config_sns_topic_arn : null

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  count = var.enable_config ? 1 : 0

  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

################################################################################
# CloudTrail
################################################################################

resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  name              = "/aws/cloudtrail/${var.name_prefix}"
  retention_in_days = 365
  kms_key_id        = local.cloudtrail_kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudtrail-logs"
  })
}

resource "aws_cloudtrail" "this" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = var.cloudtrail_s3_bucket_name
  kms_key_id                    = local.cloudtrail_kms_key_arn
  is_multi_region_trail         = var.cloudtrail_is_multi_region
  include_global_service_events = var.cloudtrail_include_global_events
  enable_log_file_validation    = var.cloudtrail_enable_log_file_validation
  enable_logging                = true

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch[0].arn

  dynamic "insight_selector" {
    for_each = var.cloudtrail_enable_insights ? [1] : []

    content {
      insight_type = "ApiCallRateInsight"
    }
  }

  dynamic "insight_selector" {
    for_each = var.cloudtrail_enable_insights ? [1] : []

    content {
      insight_type = "ApiErrorRateInsight"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-trail"
  })

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail,
  ]
}

################################################################################
# Macie
################################################################################

resource "aws_macie2_account" "this" {
  count = var.enable_macie ? 1 : 0

  finding_publishing_frequency = var.macie_finding_publishing_frequency
}

################################################################################
# IAM Access Analyzer
################################################################################

resource "aws_accessanalyzer_analyzer" "this" {
  count = var.enable_access_analyzer ? 1 : 0

  analyzer_name = "${var.name_prefix}-access-analyzer"
  type          = var.access_analyzer_type

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-access-analyzer"
  })
}

################################################################################
# Detective
################################################################################

resource "aws_detective_graph" "this" {
  count = var.enable_detective ? 1 : 0

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-detective"
  })
}

################################################################################
# IAM Password Policy
################################################################################

resource "aws_iam_account_password_policy" "this" {
  count = var.enable_iam_password_policy ? 1 : 0

  minimum_password_length        = var.password_policy_min_length
  require_symbols                = var.password_policy_require_symbols
  require_numbers                = var.password_policy_require_numbers
  require_uppercase_characters   = var.password_policy_require_uppercase
  require_lowercase_characters   = var.password_policy_require_lowercase
  max_password_age               = var.password_policy_max_age
  password_reuse_prevention      = var.password_policy_reuse_prevention
  allow_users_to_change_password = var.password_policy_allow_users_to_change
}
