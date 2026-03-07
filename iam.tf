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
  policy_arn = "arn:${local.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
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
      "arn:${local.partition}:s3:::${var.config_delivery_s3_bucket}",
      "arn:${local.partition}:s3:::${var.config_delivery_s3_bucket}/*",
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
