# GuardDuty Organization Module

Deploys and configures Amazon GuardDuty at the AWS Organization level from a delegated administrator account. Automatically enrolls member accounts and enables all protection plans.

## Usage

```hcl
module "guardduty_org" {
  source = "../../modules/guardduty-org"

  name_prefix = "myorg"

  member_accounts = [
    {
      account_id = "111111111111"
      email      = "security@example.com"
    },
  ]

  tags = {
    Environment = "security"
  }
}
```

## Requirements

- The AWS provider must be configured for the delegated GuardDuty administrator account.
- GuardDuty must be designated as a delegated administrator in AWS Organizations.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| finding_publishing_frequency | Publishing frequency | `string` | `"FIFTEEN_MINUTES"` | no |
| auto_enable_organization_members | Auto-enable mode | `string` | `"ALL"` | no |
| enable_s3_protection | Enable S3 protection | `bool` | `true` | no |
| enable_eks_protection | Enable EKS audit log monitoring | `bool` | `true` | no |
| enable_malware_protection | Enable malware protection | `bool` | `true` | no |
| member_accounts | Member accounts to enroll | `list(object)` | `[]` | no |
| publishing_destination_bucket_arn | S3 bucket ARN for findings export | `string` | `""` | no |
| publishing_destination_kms_key_arn | KMS key ARN for findings encryption | `string` | `""` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| detector_id | GuardDuty detector ID |
| detector_arn | GuardDuty detector ARN |
| member_account_ids | Enrolled member account IDs |
