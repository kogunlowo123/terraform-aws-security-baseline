################################################################################
# KMS Key for CloudTrail Encryption
################################################################################

data "aws_iam_policy_document" "cloudtrail_kms" {
  count = var.enable_cloudtrail && var.cloudtrail_kms_key_arn == "" ? 1 : 0

  # Allow root account full access
  statement {
    sid    = "EnableRootAccountAccess"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
  }

  # Allow CloudTrail to encrypt logs
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
      values   = [local.account_id]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:${local.partition}:cloudtrail:*:${local.account_id}:trail/*"]
    }
  }

  # Allow CloudTrail to describe the key
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

  # Allow CloudWatch Logs to use the key
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
      identifiers = ["logs.${local.region}.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/cloudtrail/${var.name_prefix}"]
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
