# SCP Baseline Module

Deploys foundational Service Control Policies (SCPs) to enforce security guardrails across an AWS Organization.

## Policies

| Policy | Description |
|--------|-------------|
| Deny Root Usage | Blocks all actions by the root user in member accounts |
| Deny Leaving Organization | Prevents accounts from calling `organizations:LeaveOrganization` |
| Require Encryption | Enforces encryption at rest for S3 uploads, EBS volumes, and RDS instances |

## Usage

```hcl
module "scp_baseline" {
  source = "../../modules/scp-baseline"

  name_prefix    = "myorg"
  target_ou_ids  = ["ou-abc123def456"]

  enable_deny_root_usage    = true
  enable_deny_leaving_org   = true
  enable_require_encryption = true

  tags = {
    Environment = "security"
  }
}
```

## Requirements

- The AWS provider must be configured for the AWS Organizations management account.
- SCPs must be enabled in the organization.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| target_ou_ids | OU IDs to attach policies to | `list(string)` | n/a | yes |
| enable_deny_root_usage | Enable deny-root-usage SCP | `bool` | `true` | no |
| enable_deny_leaving_org | Enable deny-leaving-org SCP | `bool` | `true` | no |
| enable_require_encryption | Enable require-encryption SCP | `bool` | `true` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| deny_root_usage_policy_id | Deny root usage SCP ID |
| deny_root_usage_policy_arn | Deny root usage SCP ARN |
| deny_leaving_org_policy_id | Deny leaving org SCP ID |
| deny_leaving_org_policy_arn | Deny leaving org SCP ARN |
| require_encryption_policy_id | Require encryption SCP ID |
| require_encryption_policy_arn | Require encryption SCP ARN |
