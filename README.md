# terraform-aws-security-baseline

Production-ready Terraform module for establishing a comprehensive AWS account security baseline. Covers GuardDuty, Security Hub, AWS Config, CloudTrail, Macie, IAM Access Analyzer, Detective, and IAM hardening.

## Architecture

This module deploys and configures the following AWS security services:

| Service | Purpose |
|---------|---------|
| **Amazon GuardDuty** | Continuous threat detection with S3, EKS, and malware protection |
| **AWS Security Hub** | Centralized security findings and compliance checks |
| **AWS Config** | Resource inventory, configuration history, and compliance auditing |
| **AWS CloudTrail** | API activity logging with KMS encryption and CloudWatch integration |
| **Amazon Macie** | Automated sensitive data discovery in S3 |
| **IAM Access Analyzer** | Identifies resources shared with external entities |
| **Amazon Detective** | Security investigation and root cause analysis |
| **IAM Password Policy** | Enforces strong password requirements |

## Usage

### Single Account Baseline

```hcl
module "security_baseline" {
  source  = "kogunlowo123/security-baseline/aws"
  version = "1.0.0"

  name_prefix = "myapp"

  # S3 buckets must exist with appropriate policies
  config_delivery_s3_bucket = "myapp-config-bucket"
  cloudtrail_s3_bucket_name = "myapp-cloudtrail-bucket"

  tags = {
    Project   = "security-baseline"
    ManagedBy = "terraform"
  }
}
```

### Enterprise Baseline with IAM Hardening

```hcl
module "security_baseline" {
  source  = "kogunlowo123/security-baseline/aws"
  version = "1.0.0"

  name_prefix = "enterprise"

  config_delivery_s3_bucket = "enterprise-config-bucket"
  cloudtrail_s3_bucket_name = "enterprise-cloudtrail-bucket"

  access_analyzer_type = "ORGANIZATION"
  enable_detective     = true

  security_hub_standards = [
    "cis-aws-foundations-benchmark/v/1.4.0",
    "aws-foundational-security-best-practices/v/1.0.0",
  ]

  tags = {
    Compliance = "cis-1.4"
  }
}

module "iam_baseline" {
  source = "kogunlowo123/security-baseline/aws//modules/iam-baseline"

  name_prefix             = "enterprise"
  create_break_glass_user = true

  security_audit_trusted_arns = [
    "arn:aws:iam::123456789012:root",
  ]
}
```

## Submodules

| Module | Description |
|--------|-------------|
| [guardduty-org](./modules/guardduty-org/) | Organization-wide GuardDuty deployment from delegated admin |
| [scp-baseline](./modules/scp-baseline/) | Service Control Policies for security guardrails |
| [iam-baseline](./modules/iam-baseline/) | IAM baseline with break-glass user and audit roles |

## CIS AWS Foundations Benchmark 1.4 Mapping

| CIS Control | Description | Module Resource |
|-------------|-------------|-----------------|
| 1.5-1.11 | IAM password policy requirements | `aws_iam_account_password_policy` |
| 1.14 | Hardware MFA for root (manual) | Documentation |
| 1.16 | IAM policies attached to groups/roles | `iam-baseline` module |
| 1.20 | Support role for AWS Support | `iam-baseline` module |
| 2.1.1 | CloudTrail enabled in all regions | `aws_cloudtrail` |
| 2.1.2 | CloudTrail log file validation | `aws_cloudtrail` |
| 2.1.4 | CloudTrail integrated with CloudWatch | `aws_cloudtrail` + `aws_cloudwatch_log_group` |
| 2.2.1 | EBS default encryption | `scp-baseline` module |
| 2.3.1 | RDS encryption | `scp-baseline` module |
| 3.1 | CloudTrail logs encrypted with KMS | `aws_kms_key` + `aws_cloudtrail` |
| 3.3 | S3 bucket access logging | Manual |
| 3.7 | Config enabled in all regions | `aws_config_configuration_recorder` |
| 4.1-4.15 | CloudWatch metric filters | Partial (CloudWatch log group created) |
| 5.1 | Security Hub enabled | `aws_securityhub_account` |

## Compliance Frameworks Supported

- **CIS AWS Foundations Benchmark v1.4.0** -- Automated controls for identity, logging, monitoring, and networking
- **AWS Foundational Security Best Practices (FSBP)** -- AWS-defined security standards via Security Hub
- **SOC 2 Type II** -- Logging, monitoring, and access control controls
- **PCI DSS** -- Encryption, access logging, and change detection
- **HIPAA** -- Audit logging, encryption, and access controls
- **NIST 800-53** -- Security and privacy controls mapping through Security Hub

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.20.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Prefix for all named resources | `string` | n/a | **yes** |
| `tags` | Map of tags for all resources | `map(string)` | `{}` | no |
| `enable_guardduty` | Enable GuardDuty | `bool` | `true` | no |
| `guardduty_s3_protection` | Enable S3 protection | `bool` | `true` | no |
| `guardduty_eks_protection` | Enable EKS protection | `bool` | `true` | no |
| `guardduty_malware_protection` | Enable malware protection | `bool` | `true` | no |
| `enable_security_hub` | Enable Security Hub | `bool` | `true` | no |
| `security_hub_standards` | Security Hub standards to enable | `list(string)` | CIS 1.4 + FSBP | no |
| `enable_config` | Enable AWS Config | `bool` | `true` | no |
| `config_delivery_s3_bucket` | S3 bucket for Config delivery | `string` | `""` | no |
| `config_sns_topic_arn` | SNS topic ARN for Config notifications | `string` | `""` | no |
| `config_all_supported_resource_types` | Record all supported resource types | `bool` | `true` | no |
| `enable_cloudtrail` | Enable CloudTrail | `bool` | `true` | no |
| `cloudtrail_s3_bucket_name` | S3 bucket for CloudTrail logs | `string` | `""` | no |
| `cloudtrail_kms_key_arn` | KMS key ARN for CloudTrail encryption | `string` | `""` | no |
| `cloudtrail_enable_log_file_validation` | Enable log file validation | `bool` | `true` | no |
| `cloudtrail_is_multi_region` | Enable multi-region trail | `bool` | `true` | no |
| `cloudtrail_include_global_events` | Include global service events | `bool` | `true` | no |
| `cloudtrail_enable_insights` | Enable CloudTrail Insights | `bool` | `true` | no |
| `enable_macie` | Enable Macie | `bool` | `true` | no |
| `macie_finding_publishing_frequency` | Macie publishing frequency | `string` | `"FIFTEEN_MINUTES"` | no |
| `enable_access_analyzer` | Enable Access Analyzer | `bool` | `true` | no |
| `access_analyzer_type` | Access Analyzer type (ACCOUNT/ORGANIZATION) | `string` | `"ACCOUNT"` | no |
| `enable_detective` | Enable Detective | `bool` | `false` | no |
| `enable_iam_password_policy` | Configure IAM password policy | `bool` | `true` | no |
| `password_policy_min_length` | Minimum password length | `number` | `14` | no |
| `password_policy_require_symbols` | Require symbols | `bool` | `true` | no |
| `password_policy_require_numbers` | Require numbers | `bool` | `true` | no |
| `password_policy_require_uppercase` | Require uppercase | `bool` | `true` | no |
| `password_policy_require_lowercase` | Require lowercase | `bool` | `true` | no |
| `password_policy_max_age` | Password max age in days | `number` | `90` | no |
| `password_policy_reuse_prevention` | Password reuse prevention count | `number` | `24` | no |
| `password_policy_allow_users_to_change` | Allow users to change passwords | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| `guardduty_detector_id` | GuardDuty detector ID |
| `guardduty_detector_arn` | GuardDuty detector ARN |
| `securityhub_account_id` | Security Hub account ID |
| `securityhub_account_arn` | Security Hub account ARN |
| `securityhub_standards_subscription_arns` | Enabled standards subscription ARNs |
| `config_recorder_id` | Config recorder ID |
| `config_delivery_channel_id` | Config delivery channel ID |
| `config_role_arn` | Config recorder IAM role ARN |
| `cloudtrail_id` | CloudTrail trail name |
| `cloudtrail_arn` | CloudTrail trail ARN |
| `cloudtrail_home_region` | CloudTrail home region |
| `cloudtrail_cloudwatch_log_group_arn` | CloudWatch log group ARN for CloudTrail |
| `cloudtrail_cloudwatch_role_arn` | CloudTrail CloudWatch IAM role ARN |
| `cloudtrail_kms_key_arn` | KMS key ARN for CloudTrail encryption |
| `cloudtrail_kms_key_id` | KMS key ID for CloudTrail encryption |
| `macie_account_id` | Macie account ID |
| `access_analyzer_id` | Access Analyzer ID |
| `access_analyzer_arn` | Access Analyzer ARN |
| `detective_graph_id` | Detective graph ID |
| `detective_graph_arn` | Detective graph ARN |
| `iam_password_policy_expire_passwords` | Whether passwords expire |

## Examples

- [Basic single account](./examples/basic/) -- Minimal baseline for a single AWS account
- [Complete enterprise](./examples/complete/) -- Full enterprise baseline with all services and IAM hardening

## License

MIT License. See [LICENSE](./LICENSE) for details.
