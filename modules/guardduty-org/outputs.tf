output "detector_id" {
  description = "ID of the organization GuardDuty detector."
  value       = aws_guardduty_detector.admin.id
}

output "detector_arn" {
  description = "ARN of the organization GuardDuty detector."
  value       = aws_guardduty_detector.admin.arn
}

output "member_account_ids" {
  description = "List of member account IDs enrolled in GuardDuty."
  value       = [for m in aws_guardduty_member.members : m.account_id]
}
