terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.0"
    }
  }
}

################################################################################
# SCP: Deny Root Account Usage
################################################################################

data "aws_iam_policy_document" "deny_root_usage" {
  statement {
    sid    = "DenyRootAccountUsage"
    effect = "Deny"
    actions = [
      "*",
    ]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

resource "aws_organizations_policy" "deny_root_usage" {
  count = var.enable_deny_root_usage ? 1 : 0

  name        = "${var.name_prefix}-deny-root-usage"
  description = "Denies the use of the root user in all member accounts."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_root_usage.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-deny-root-usage"
  })
}

resource "aws_organizations_policy_attachment" "deny_root_usage" {
  for_each = var.enable_deny_root_usage ? toset(var.target_ou_ids) : toset([])

  policy_id = aws_organizations_policy.deny_root_usage[0].id
  target_id = each.value
}

################################################################################
# SCP: Deny Leaving Organization
################################################################################

data "aws_iam_policy_document" "deny_leaving_org" {
  statement {
    sid    = "DenyLeavingOrganization"
    effect = "Deny"
    actions = [
      "organizations:LeaveOrganization",
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_leaving_org" {
  count = var.enable_deny_leaving_org ? 1 : 0

  name        = "${var.name_prefix}-deny-leaving-org"
  description = "Prevents member accounts from leaving the AWS Organization."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.deny_leaving_org.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-deny-leaving-org"
  })
}

resource "aws_organizations_policy_attachment" "deny_leaving_org" {
  for_each = var.enable_deny_leaving_org ? toset(var.target_ou_ids) : toset([])

  policy_id = aws_organizations_policy.deny_leaving_org[0].id
  target_id = each.value
}

################################################################################
# SCP: Require Encryption at Rest
################################################################################

data "aws_iam_policy_document" "require_encryption" {
  statement {
    sid    = "DenyUnencryptedS3Uploads"
    effect = "Deny"
    actions = [
      "s3:PutObject",
    ]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms", "AES256"]
    }
  }

  statement {
    sid    = "DenyUnencryptedS3UploadsNoHeader"
    effect = "Deny"
    actions = [
      "s3:PutObject",
    ]
    resources = ["*"]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  statement {
    sid    = "DenyUnencryptedEBSVolumes"
    effect = "Deny"
    actions = [
      "ec2:CreateVolume",
    ]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "ec2:Encrypted"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DenyUnencryptedRDSInstances"
    effect = "Deny"
    actions = [
      "rds:CreateDBInstance",
      "rds:CreateDBCluster",
    ]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "rds:StorageEncrypted"
      values   = ["false"]
    }
  }
}

resource "aws_organizations_policy" "require_encryption" {
  count = var.enable_require_encryption ? 1 : 0

  name        = "${var.name_prefix}-require-encryption"
  description = "Requires encryption at rest for S3, EBS, and RDS resources."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.require_encryption.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-require-encryption"
  })
}

resource "aws_organizations_policy_attachment" "require_encryption" {
  for_each = var.enable_require_encryption ? toset(var.target_ou_ids) : toset([])

  policy_id = aws_organizations_policy.require_encryption[0].id
  target_id = each.value
}
