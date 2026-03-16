output "guardduty_detector_id" {
  description = "ID of the GuardDuty detector."
  value       = try(aws_guardduty_detector.this[0].id, null)
}

output "guardduty_detector_arn" {
  description = "ARN of the GuardDuty detector."
  value       = try(aws_guardduty_detector.this[0].arn, null)
}

output "securityhub_account_id" {
  description = "ID of the Security Hub account resource."
  value       = try(aws_securityhub_account.this[0].id, null)
}

output "securityhub_account_arn" {
  description = "ARN of the Security Hub account."
  value       = try(aws_securityhub_account.this[0].arn, null)
}

output "securityhub_standards_subscription_arns" {
  description = "ARNs of the enabled Security Hub standards subscriptions."
  value       = [for s in aws_securityhub_standards_subscription.this : s.id]
}

output "config_recorder_id" {
  description = "ID of the AWS Config configuration recorder."
  value       = try(aws_config_configuration_recorder.this[0].id, null)
}

output "config_delivery_channel_id" {
  description = "ID of the AWS Config delivery channel."
  value       = try(aws_config_delivery_channel.this[0].id, null)
}

output "config_role_arn" {
  description = "ARN of the IAM role used by the AWS Config recorder."
  value       = try(aws_iam_role.config[0].arn, null)
}

output "cloudtrail_id" {
  description = "Name of the CloudTrail trail."
  value       = try(aws_cloudtrail.this[0].id, null)
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = try(aws_cloudtrail.this[0].arn, null)
}

output "cloudtrail_home_region" {
  description = "Home region of the CloudTrail trail."
  value       = try(aws_cloudtrail.this[0].home_region, null)
}

output "cloudtrail_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for CloudTrail."
  value       = try(aws_cloudwatch_log_group.cloudtrail[0].arn, null)
}

output "cloudtrail_cloudwatch_role_arn" {
  description = "ARN of the IAM role for CloudTrail CloudWatch integration."
  value       = try(aws_iam_role.cloudtrail_cloudwatch[0].arn, null)
}

output "cloudtrail_kms_key_arn" {
  description = "ARN of the KMS key used for CloudTrail encryption."
  value       = var.cloudtrail_kms_key_arn != "" ? var.cloudtrail_kms_key_arn : try(aws_kms_key.cloudtrail[0].arn, null)
}

output "cloudtrail_kms_key_id" {
  description = "ID of the KMS key created for CloudTrail encryption."
  value       = try(aws_kms_key.cloudtrail[0].key_id, null)
}

output "macie_account_id" {
  description = "ID of the Macie account."
  value       = try(aws_macie2_account.this[0].id, null)
}

output "access_analyzer_id" {
  description = "ID of the IAM Access Analyzer."
  value       = try(aws_accessanalyzer_analyzer.this[0].id, null)
}

output "access_analyzer_arn" {
  description = "ARN of the IAM Access Analyzer."
  value       = try(aws_accessanalyzer_analyzer.this[0].arn, null)
}

output "detective_graph_id" {
  description = "ID of the Detective graph."
  value       = try(aws_detective_graph.this[0].id, null)
}

output "detective_graph_arn" {
  description = "ARN of the Detective graph."
  value       = try(aws_detective_graph.this[0].graph_arn, null)
}

output "iam_password_policy_expire_passwords" {
  description = "Whether the IAM password policy requires passwords to expire."
  value       = try(aws_iam_account_password_policy.this[0].expire_passwords, null)
}
