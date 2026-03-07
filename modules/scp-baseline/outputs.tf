output "deny_root_usage_policy_id" {
  description = "ID of the deny-root-usage SCP."
  value       = try(aws_organizations_policy.deny_root_usage[0].id, null)
}

output "deny_root_usage_policy_arn" {
  description = "ARN of the deny-root-usage SCP."
  value       = try(aws_organizations_policy.deny_root_usage[0].arn, null)
}

output "deny_leaving_org_policy_id" {
  description = "ID of the deny-leaving-org SCP."
  value       = try(aws_organizations_policy.deny_leaving_org[0].id, null)
}

output "deny_leaving_org_policy_arn" {
  description = "ARN of the deny-leaving-org SCP."
  value       = try(aws_organizations_policy.deny_leaving_org[0].arn, null)
}

output "require_encryption_policy_id" {
  description = "ID of the require-encryption SCP."
  value       = try(aws_organizations_policy.require_encryption[0].id, null)
}

output "require_encryption_policy_arn" {
  description = "ARN of the require-encryption SCP."
  value       = try(aws_organizations_policy.require_encryption[0].arn, null)
}
