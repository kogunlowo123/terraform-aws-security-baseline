# Basic Example

Deploys the AWS security baseline for a single account with sensible defaults. Enables GuardDuty, Security Hub, AWS Config, CloudTrail, Macie, Access Analyzer, and IAM password policy.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Prerequisites

- An S3 bucket for AWS Config delivery (`myapp-config-bucket`)
- An S3 bucket for CloudTrail logs (`myapp-cloudtrail-bucket`) with the appropriate bucket policy

## Notes

- Detective is disabled by default due to its cost and dependency on GuardDuty running for 48 hours.
- EKS protection is disabled in this example since no EKS clusters are assumed.
- A KMS key is automatically created for CloudTrail encryption.
