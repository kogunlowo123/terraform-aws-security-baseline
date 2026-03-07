# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-01

### Added

- Amazon GuardDuty detector with S3, EKS, and malware protection plans.
- AWS Security Hub with CIS AWS Foundations Benchmark v1.4 and AWS FSBP standards.
- AWS Config configuration recorder, delivery channel, and IAM role.
- AWS CloudTrail with multi-region support, log file validation, CloudWatch integration, and KMS encryption.
- CloudWatch Log Group for CloudTrail log delivery.
- KMS key for CloudTrail encryption (created automatically when not provided).
- Amazon Macie account enablement with configurable publishing frequency.
- IAM Access Analyzer (ACCOUNT or ORGANIZATION type).
- Amazon Detective graph (disabled by default).
- IAM account password policy aligned to CIS benchmarks.
- IAM roles for Config recorder and CloudTrail CloudWatch delivery.
- `guardduty-org` submodule for organization-wide GuardDuty deployment.
- `scp-baseline` submodule with deny-root-usage, deny-leaving-org, and require-encryption SCPs.
- `iam-baseline` submodule with break-glass user, security audit role, and support role.
- Basic single-account example.
- Complete enterprise example with all services and IAM hardening.
