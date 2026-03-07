output "break_glass_user_name" {
  description = "Name of the break-glass IAM user."
  value       = try(aws_iam_user.break_glass[0].name, null)
}

output "break_glass_user_arn" {
  description = "ARN of the break-glass IAM user."
  value       = try(aws_iam_user.break_glass[0].arn, null)
}

output "security_audit_role_arn" {
  description = "ARN of the security audit IAM role."
  value       = try(aws_iam_role.security_audit[0].arn, null)
}

output "security_audit_role_name" {
  description = "Name of the security audit IAM role."
  value       = try(aws_iam_role.security_audit[0].name, null)
}

output "support_role_arn" {
  description = "ARN of the AWS Support access IAM role."
  value       = try(aws_iam_role.support[0].arn, null)
}

output "support_role_name" {
  description = "Name of the AWS Support access IAM role."
  value       = try(aws_iam_role.support[0].name, null)
}
