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
data "aws_region" "current" {}

################################################################################
# Organization-wide GuardDuty Detector (Delegated Admin Account)
################################################################################

resource "aws_guardduty_detector" "admin" {
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency

  datasources {
    s3_logs {
      enable = var.enable_s3_protection
    }

    kubernetes {
      audit_logs {
        enable = var.enable_eks_protection
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = var.enable_malware_protection
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-guardduty-org"
  })
}

resource "aws_guardduty_organization_configuration" "this" {
  auto_enable_organization_members = var.auto_enable_organization_members
  detector_id                      = aws_guardduty_detector.admin.id

  datasources {
    s3_logs {
      auto_enable = var.enable_s3_protection
    }

    kubernetes {
      audit_logs {
        enable = var.enable_eks_protection
      }
    }

    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = var.enable_malware_protection
        }
      }
    }
  }
}

resource "aws_guardduty_member" "members" {
  for_each = { for m in var.member_accounts : m.account_id => m }

  account_id  = each.value.account_id
  detector_id = aws_guardduty_detector.admin.id
  email       = each.value.email
  invite      = true

  lifecycle {
    ignore_changes = [invite]
  }
}

resource "aws_guardduty_publishing_destination" "this" {
  count = var.publishing_destination_bucket_arn != "" ? 1 : 0

  detector_id     = aws_guardduty_detector.admin.id
  destination_arn = var.publishing_destination_bucket_arn
  kms_key_arn     = var.publishing_destination_kms_key_arn
}
