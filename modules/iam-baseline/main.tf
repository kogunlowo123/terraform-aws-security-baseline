terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
}

################################################################################
# Break-Glass IAM User
################################################################################

resource "aws_iam_user" "break_glass" {
  count = var.create_break_glass_user ? 1 : 0

  name          = "${var.name_prefix}-break-glass"
  path          = "/emergency/"
  force_destroy = false

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-break-glass"
    Purpose = "emergency-access"
  })
}

data "aws_iam_policy_document" "break_glass" {
  count = var.create_break_glass_user ? 1 : 0

  statement {
    sid    = "BreakGlassAdministratorAccess"
    effect = "Allow"
    actions = [
      "*",
    ]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_user_policy" "break_glass" {
  count = var.create_break_glass_user ? 1 : 0

  name   = "${var.name_prefix}-break-glass-admin"
  user   = aws_iam_user.break_glass[0].name
  policy = data.aws_iam_policy_document.break_glass[0].json
}

################################################################################
# Security Audit Role (read-only cross-account access)
################################################################################

data "aws_iam_policy_document" "security_audit_assume" {
  count = var.create_security_audit_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.security_audit_trusted_arns
    }

    dynamic "condition" {
      for_each = var.require_mfa_for_audit_role ? [1] : []

      content {
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values   = ["true"]
      }
    }
  }
}

resource "aws_iam_role" "security_audit" {
  count = var.create_security_audit_role ? 1 : 0

  name               = "${var.name_prefix}-security-audit"
  path               = "/security/"
  assume_role_policy = data.aws_iam_policy_document.security_audit_assume[0].json
  max_session_duration = 3600

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-security-audit"
  })
}

resource "aws_iam_role_policy_attachment" "security_audit" {
  count = var.create_security_audit_role ? 1 : 0

  role       = aws_iam_role.security_audit[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "security_audit_config" {
  count = var.create_security_audit_role ? 1 : 0

  role       = aws_iam_role.security_audit[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/AWS_ConfigRole"
}

################################################################################
# Support Role (for AWS Support access)
################################################################################

data "aws_iam_policy_document" "support_assume" {
  count = var.create_support_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "support" {
  count = var.create_support_role ? 1 : 0

  name               = "${var.name_prefix}-support-access"
  path               = "/security/"
  assume_role_policy = data.aws_iam_policy_document.support_assume[0].json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-support-access"
  })
}

resource "aws_iam_role_policy_attachment" "support" {
  count = var.create_support_role ? 1 : 0

  role       = aws_iam_role.support[0].name
  policy_arn = "arn:${local.partition}:iam::aws:policy/AWSSupportAccess"
}
