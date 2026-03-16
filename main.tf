data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

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

  standards_arn = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standards/${each.value}"

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
  kms_key_id        = var.cloudtrail_kms_key_arn != "" ? var.cloudtrail_kms_key_arn : try(aws_kms_key.cloudtrail[0].arn, "")

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudtrail-logs"
  })
}

resource "aws_cloudtrail" "this" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.name_prefix}-trail"
  s3_bucket_name                = var.cloudtrail_s3_bucket_name
  kms_key_id                    = var.cloudtrail_kms_key_arn != "" ? var.cloudtrail_kms_key_arn : try(aws_kms_key.cloudtrail[0].arn, "")
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

################################################################################
# AWS Config - IAM Role
################################################################################

data "aws_iam_policy_document" "config_assume" {
  count = var.enable_config ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0

  name               = "${var.name_prefix}-config-recorder-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume[0].json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-config-recorder-role"
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  count = var.enable_config ? 1 : 0

  role       = aws_iam_role.config[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "config_s3" {
  count = var.enable_config ? 1 : 0

  statement {
    sid    = "AllowConfigS3Delivery"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${var.config_delivery_s3_bucket}",
      "arn:${data.aws_partition.current.partition}:s3:::${var.config_delivery_s3_bucket}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_iam_role_policy" "config_s3" {
  count = var.enable_config ? 1 : 0

  name   = "${var.name_prefix}-config-s3-delivery"
  role   = aws_iam_role.config[0].id
  policy = data.aws_iam_policy_document.config_s3[0].json
}

################################################################################
# CloudTrail - CloudWatch Logs IAM Role
################################################################################

data "aws_iam_policy_document" "cloudtrail_cloudwatch_assume" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0

  name               = "${var.name_prefix}-cloudtrail-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_cloudwatch_assume[0].json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudtrail-cloudwatch-role"
  })
}

data "aws_iam_policy_document" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0

  statement {
    sid    = "AllowCloudTrailCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch" {
  count = var.enable_cloudtrail ? 1 : 0

  name   = "${var.name_prefix}-cloudtrail-cloudwatch-logs"
  role   = aws_iam_role.cloudtrail_cloudwatch[0].id
  policy = data.aws_iam_policy_document.cloudtrail_cloudwatch[0].json
}

################################################################################
# KMS Key for CloudTrail Encryption
################################################################################

data "aws_iam_policy_document" "cloudtrail_kms" {
  count = var.enable_cloudtrail && var.cloudtrail_kms_key_arn == "" ? 1 : 0

  statement {
    sid    = "EnableRootAccountAccess"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowCloudTrailEncrypt"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid    = "AllowCloudTrailDescribeKey"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowCloudWatchLogsEncrypt"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/cloudtrail/${var.name_prefix}"]
    }
  }
}

resource "aws_kms_key" "cloudtrail" {
  count = var.enable_cloudtrail && var.cloudtrail_kms_key_arn == "" ? 1 : 0

  description             = "KMS key for CloudTrail log encryption - ${var.name_prefix}"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.cloudtrail_kms[0].json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudtrail-kms"
  })
}

resource "aws_kms_alias" "cloudtrail" {
  count = var.enable_cloudtrail && var.cloudtrail_kms_key_arn == "" ? 1 : 0

  name          = "alias/${var.name_prefix}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}
