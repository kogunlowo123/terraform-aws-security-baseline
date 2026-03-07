# IAM Baseline Module

Establishes IAM security best practices including a break-glass emergency user, security audit role, and AWS Support access role.

## Resources

| Resource | Description |
|----------|-------------|
| Break-Glass User | Emergency admin user requiring MFA, for use when SSO/IdP is unavailable |
| Security Audit Role | Read-only cross-account role for security assessments |
| Support Role | Role for accessing AWS Support, requires MFA |

## Usage

```hcl
module "iam_baseline" {
  source = "../../modules/iam-baseline"

  name_prefix = "myorg"

  create_break_glass_user    = true
  create_security_audit_role = true
  create_support_role        = true

  security_audit_trusted_arns = [
    "arn:aws:iam::123456789012:root",
  ]

  tags = {
    Environment = "security"
  }
}
```

## Important Notes

- The break-glass user requires MFA for all actions. Store credentials securely (e.g., in a physical safe).
- Rotate break-glass credentials on a regular schedule and after every use.
- The security audit role grants `SecurityAudit` and `AWS_ConfigRole` managed policies.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| create_break_glass_user | Create emergency IAM user | `bool` | `true` | no |
| create_security_audit_role | Create security audit role | `bool` | `true` | no |
| security_audit_trusted_arns | ARNs trusted to assume audit role | `list(string)` | `[]` | no |
| require_mfa_for_audit_role | Require MFA for audit role | `bool` | `true` | no |
| create_support_role | Create AWS Support role | `bool` | `true` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| break_glass_user_name | Break-glass IAM user name |
| break_glass_user_arn | Break-glass IAM user ARN |
| security_audit_role_arn | Security audit role ARN |
| security_audit_role_name | Security audit role name |
| support_role_arn | Support access role ARN |
| support_role_name | Support access role name |
