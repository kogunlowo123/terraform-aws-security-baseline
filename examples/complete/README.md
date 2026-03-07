# Complete Enterprise Example

Deploys the full AWS security baseline for an enterprise environment including all security services, IAM hardening, and organization-level configurations.

## Features Enabled

- **GuardDuty** with S3, EKS, and malware protection
- **Security Hub** with CIS 1.4 and AWS FSBP standards
- **AWS Config** with full resource recording and SNS notifications
- **CloudTrail** multi-region with insights, log validation, and KMS encryption
- **Macie** with 15-minute finding publishing
- **Access Analyzer** at organization level
- **Detective** for security investigation
- **IAM Password Policy** aligned to CIS benchmarks
- **Break-glass IAM user** with MFA requirement
- **Security audit role** for cross-account assessments
- **AWS Support role** with MFA requirement

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- S3 buckets for Config and CloudTrail delivery with appropriate bucket policies
- AWS Organizations configured (for organization-level Access Analyzer)
- GuardDuty must be running for 48 hours before Detective can be enabled

## CIS Benchmark Coverage

This example addresses the following CIS AWS Foundations Benchmark 1.4 controls:

| Control | Description | Status |
|---------|-------------|--------|
| 1.4 | Ensure access keys are rotated every 90 days | Manual |
| 1.5-1.11 | IAM password policy | Automated |
| 2.1 | CloudTrail enabled in all regions | Automated |
| 2.2 | CloudTrail log file validation | Automated |
| 2.4 | CloudTrail integrated with CloudWatch | Automated |
| 2.7 | CloudTrail logs encrypted with KMS | Automated |
| 2.5 | AWS Config enabled | Automated |
| 3.x | Monitoring and alerting | Partial |
| 4.1 | Security Hub enabled | Automated |
