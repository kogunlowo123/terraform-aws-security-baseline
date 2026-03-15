# Industry Adaptation Guide

## Overview
The `terraform-aws-security-baseline` module enables a comprehensive AWS security posture by configuring GuardDuty, Security Hub, AWS Config, CloudTrail, Macie, IAM Access Analyzer, Amazon Detective, and IAM password policies. It provides the foundational security controls required across all regulated industries.

## Healthcare
### Compliance Requirements
- HIPAA, HITRUST, HL7 FHIR
### Configuration Changes
- Set `enable_guardduty = true` with `guardduty_s3_protection = true` and `guardduty_malware_protection = true` to detect threats against PHI stored in S3 and EBS.
- Set `enable_security_hub = true` and add `"nist-800-53/v/5.0.0"` to `security_hub_standards` (HIPAA maps to NIST controls).
- Set `enable_config = true` with `config_all_supported_resource_types = true` for continuous configuration compliance monitoring.
- Set `enable_cloudtrail = true` with `cloudtrail_is_multi_region = true`, `cloudtrail_enable_log_file_validation = true`, and `cloudtrail_enable_insights = true` for HIPAA audit controls.
- Set `enable_macie = true` with `macie_finding_publishing_frequency = "FIFTEEN_MINUTES"` to detect PHI in S3 buckets.
- Set `enable_access_analyzer = true` to identify resources shared externally (potential PHI exposure).
- Configure `password_policy_min_length = 14` and `password_policy_max_age = 90` for HIPAA access controls.
### Example Use Case
A healthcare organization enables the full security baseline with Macie scanning S3 buckets for PHI, GuardDuty monitoring for unauthorized access patterns, and Security Hub evaluating NIST 800-53 controls mapped to HIPAA requirements.

## Finance
### Compliance Requirements
- SOX, PCI-DSS, SOC 2
### Configuration Changes
- Set `enable_security_hub = true` with `security_hub_standards` including `"pci-dss/v/3.2.1"` for automated PCI compliance checks.
- Set `enable_cloudtrail = true` with `cloudtrail_is_multi_region = true` and provide a dedicated `cloudtrail_s3_bucket_name` with a `cloudtrail_kms_key_arn` for encrypted, tamper-proof audit logs (SOX Section 802).
- Set `enable_guardduty = true` with all protections enabled for real-time threat detection.
- Set `enable_config = true` with `config_sns_topic_arn` set to alert on configuration drift.
- Set `enable_detective = true` for forensic investigation of security incidents.
- Set `enable_access_analyzer = true` with `access_analyzer_type = "ORGANIZATION"` for enterprise-wide public access detection.
- Configure `password_policy_reuse_prevention = 24` and `password_policy_min_length = 14` for PCI-DSS Requirement 8.
### Example Use Case
A bank enables the security baseline with PCI-DSS Security Hub standard, multi-region encrypted CloudTrail, GuardDuty with EKS and S3 protection, and Amazon Detective for SOC analyst investigations of suspicious transaction patterns.

## Government
### Compliance Requirements
- FedRAMP, CMMC, NIST 800-53
### Configuration Changes
- Set `enable_security_hub = true` with `security_hub_standards` including both `"nist-800-53/v/5.0.0"` and `"cis-aws-foundations-benchmark/v/1.4.0"`.
- Set `enable_cloudtrail = true` with `cloudtrail_is_multi_region = true`, `cloudtrail_include_global_events = true`, `cloudtrail_enable_log_file_validation = true`, and `cloudtrail_enable_insights = true` (NIST AU-2, AU-3, AU-6, AU-12).
- Provide `cloudtrail_kms_key_arn` pointing to a FIPS-validated KMS key (NIST SC-28).
- Set `enable_guardduty = true` with `guardduty_eks_protection = true` and `guardduty_malware_protection = true` (NIST SI-4).
- Set `enable_config = true` for continuous monitoring (NIST CM-3, CM-6).
- Set `enable_access_analyzer = true` with `access_analyzer_type = "ORGANIZATION"` (NIST AC-6).
- Set `enable_detective = true` for incident investigation (NIST IR-4, IR-5).
- Configure strict password policy: `password_policy_min_length = 14`, `password_policy_max_age = 60`, `password_policy_reuse_prevention = 24`.
### Example Use Case
A government contractor enables all seven security services for its FedRAMP High environment, with NIST 800-53 Security Hub checks, FIPS-encrypted CloudTrail, organization-wide Access Analyzer, and Detective for incident response workflows.

## Retail / E-Commerce
### Compliance Requirements
- PCI-DSS, CCPA/GDPR
### Configuration Changes
- Set `enable_security_hub = true` with `security_hub_standards` including `"pci-dss/v/3.2.1"`.
- Set `enable_guardduty = true` with `guardduty_s3_protection = true` to detect unauthorized access to customer data stored in S3.
- Set `enable_macie = true` to discover and classify PII (credit card numbers, customer addresses) in S3 buckets.
- Set `enable_cloudtrail = true` for audit trails of API actions affecting customer data.
- Set `enable_config = true` with `config_sns_topic_arn` for alerting on infrastructure changes impacting PCI scope.
- Configure `password_policy_min_length = 12` and enable all character requirements.
### Example Use Case
A retailer enables Macie to scan product image and order data buckets for accidentally stored credit card numbers, GuardDuty to detect credential compromise, and Security Hub with PCI-DSS standards to maintain continuous compliance.

## Education
### Compliance Requirements
- FERPA, COPPA
### Configuration Changes
- Set `enable_guardduty = true` with `guardduty_s3_protection = true` to monitor S3 buckets containing student records.
- Set `enable_macie = true` to detect student PII in data stores.
- Set `enable_cloudtrail = true` with `cloudtrail_enable_log_file_validation = true` for tamper-proof audit logs of access to student data.
- Set `enable_config = true` to track configuration changes to resources hosting FERPA-protected data.
- Set `enable_access_analyzer = true` to detect unintended public sharing of educational resources containing student data.
- Configure `enable_iam_password_policy = true` with appropriate complexity requirements.
### Example Use Case
A state education department uses the security baseline to monitor its AWS environment hosting student assessment data, with Macie scanning for student SSNs, Access Analyzer detecting public S3 buckets, and CloudTrail logging all data access.

## SaaS / Multi-Tenant
### Compliance Requirements
- SOC 2, ISO 27001
### Configuration Changes
- Set `enable_security_hub = true` with `security_hub_standards` including `"aws-foundational-security-best-practices/v/1.0.0"` and `"cis-aws-foundations-benchmark/v/1.4.0"`.
- Set `enable_guardduty = true` with all protections enabled for comprehensive threat detection.
- Set `enable_cloudtrail = true` with `cloudtrail_is_multi_region = true` for SOC 2 CC6.1 and CC7.2 audit trail requirements.
- Set `enable_config = true` for change management evidence (SOC 2 CC8.1).
- Set `enable_access_analyzer = true` with `access_analyzer_type = "ORGANIZATION"` to prevent cross-tenant data leakage via misconfigured IAM policies.
- Set `enable_detective = true` for incident response capabilities.
- Set `macie_finding_publishing_frequency = "FIFTEEN_MINUTES"` for rapid PII detection.
### Example Use Case
A SaaS company enables the full security baseline for its SOC 2 Type II audit, using Security Hub for automated control evidence, Config for change management tracking, and Access Analyzer to prove no tenant data is publicly accessible.

## Cross-Industry Best Practices
- Enable environment-based configuration by parameterizing `name_prefix` and `tags` per environment.
- Always enable encryption by providing `cloudtrail_kms_key_arn` for at-rest encryption of audit logs.
- Enable comprehensive audit logging by setting `enable_cloudtrail = true` with multi-region coverage and log file validation.
- Enforce least-privilege access controls by enabling `enable_access_analyzer = true` and `enable_iam_password_policy = true`.
- Implement monitoring with `enable_guardduty = true`, `enable_security_hub = true`, and `enable_config = true`.
- Plan for incident response by enabling `enable_detective = true` for forensic investigation capabilities.
