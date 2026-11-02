---
name: terraform-aws-govcloud
description: Write, review or explain Terraform for AWS GovCloud (US) under FedRAMP and NIST 800-53. Use when the target is partition aws-us-gov, region us-gov-west-1 or us-gov-east-1, or the task mentions GovCloud, FedRAMP, FIPS or NIST controls.
---

# Terraform on AWS GovCloud (FedRAMP)

## Differences from commercial AWS to check every time

- Partition is `aws-us-gov`. ARNs start `arn:aws-us-gov:`. Never hardcode `arn:aws:`. Use `data.aws_partition.current.partition`.
- Regions are `us-gov-west-1` and `us-gov-east-1`. Default regions in modules written for commercial AWS (`us-east-1`) are bugs here.
- Provider block: set `use_fips_endpoint = true`. If a service has no FIPS endpoint, say so instead of silently dropping it.
- Accounts, IAM and credentials are separate from commercial. Nothing is shared by default.
- Service and feature availability differs. Before using a service, confirm it exists in GovCloud (US) and has the feature. If you cannot confirm from the code or docs, say "cannot verify".
- AMI IDs, load balancer log delivery accounts and some service principals differ. Look them up with data sources (`aws_ami`, `aws_elb_service_account`) instead of copying IDs from commercial examples.

## Baseline for every change

| Area | Do | Control |
|---|---|---|
| Keys | Customer managed KMS key, `enable_key_rotation = true`, scoped key policy | SC-12, SC-28 |
| S3 | SSE-KMS, all four public access blocks, versioning, access logging, deny `aws:SecureTransport = false` | SC-28, SC-8, AC-3 |
| State | S3 backend in a GovCloud region, `encrypt = true`, `use_lockfile = true` (Terraform 1.10+) | SC-28, CP-9 |
| Network | Private subnets, VPC endpoints for S3, KMS, STS and logs, flow logs, default security group emptied | SC-7, AU-12 |
| Access | No `0.0.0.0/0` on admin ports, prefer SSM Session Manager over SSH | SC-7, AC-17 |
| IAM | Roles not users, named actions on named ARNs, no `*` actions or resources | AC-2, AC-6 |
| Compute | IMDSv2 required (`http_tokens = "required"`), encrypted volumes with the CMK, no public IP | AC-6, SC-28 |
| Audit | Multi-region CloudTrail, `enable_log_file_validation`, KMS, CloudWatch Logs | AU-2, AU-9, AU-10 |
| Detection | Config, GuardDuty, Security Hub are an account baseline. Ask if they exist before adding them | SI-4, CM-8 |

## Network and security group rules

- Spread subnets, tasks and databases across three AZs (`az_count` variable, 2 or 3, validated, default 3). Size the minimum capacity so any two AZs carry peak load, because capacity must exist before an AZ fails. Interface endpoints bill per AZ, so build only the ones the enabled workloads call.
- Empty the default security group with `aws_default_security_group` and no rules, so nothing attaches to it by accident. Scanners flag it for this reason.
- Workload groups get no inbound rules unless something truly needs them. Endpoint and database groups accept traffic only from a referenced security group (`referenced_security_group_id`), never a CIDR, so the rule follows the workload when IPs change.
- Write rules as separate `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources, one per port and source. Do not use inline `ingress` and `egress` blocks, and do not use `aws_security_group_rule`. Separate rules avoid dependency cycles between groups that reference each other (for example ECS and the database).
- Security groups are the main control: stateful, attached to ENIs. Network ACLs are stateless and sit on subnets, so add them only as a coarse extra layer and remember they need return-traffic rules.
- Egress is explicit. Prefer HTTPS to the VPC endpoints over open egress. If a rule must be wide, say why in a comment.

## How to work

1. Read the existing code first. Name the partition, region, and state backend you found.
2. Make the smallest change that fixes one finding. Show the diff.
3. Run `make fmt validate lint scan`. Report each failure with file and line.
4. Never run `apply`, `destroy`, `import`, `state` or any `aws` command. Propose it and explain what it changes. The human runs `plan` in a separate terminal that holds the credentials.
5. When mapping to controls, mark each item met, partly met, missing, or cannot verify. Quote the line that supports every "met".
6. Call out over-engineering for the stack in front of you, with a reason. Do not add controls just because a scanner listed them.
7. Never print or ask for credentials, session tokens, account IDs or real ARNs.

## Service gotchas that break a plan or an apply

- S3 server access log delivery cannot write to a KMS-encrypted bucket. The log target bucket uses SSE-S3 (`AES256`).
- A CMK key policy must name the services that use it: `logs.<region>.amazonaws.com` for log groups, `cloudtrail.amazonaws.com`, and `sns.amazonaws.com` plus `cloudwatch.amazonaws.com` when SNS topics or SQS queues use the key. Without them, alarms and fan-out fail silently.
- Private ECS and EKS need endpoints for `ecr.api`, `ecr.dkr`, `logs`, plus `sqs`, `kms`, `secretsmanager`, `sts` and `ec2` as used, and the S3 gateway endpoint for image layers. No NAT means a missing endpoint is a hung task.
- RDS: `manage_master_user_password = true` (no password in code or state), `rds.force_ssl = 1`, Multi-AZ, `deletion_protection`, a final snapshot, and a backup retention period for point-in-time restore.
- EKS: private API endpoint, secrets encrypted with the CMK (the cluster role needs `kms:Encrypt`, `Decrypt`, `ListGrants`, `DescribeKey`), access entries instead of aws-auth. A CMK on node EBS volumes needs a key grant for the Auto Scaling service-linked role.
- SQS: set a dead-letter queue with a redrive limit, a visibility timeout of at least 6x the consumer timeout, and an alarm on the DLQ.
- CloudTrail to S3 alone gives no alerting. At Moderate, stream it to CloudWatch Logs and add metric filters, or say it is missing.
- Gate optional features behind `enable_*` variables with validation, so a plan fails early instead of halfway through an apply.

## Service differences in GovCloud (US)

Source: AWS GovCloud (US) User Guide, service pages. These change over time. If a request depends on one, say "cannot verify" unless the docs are in front of you.

- **S3:**
  - No private DNS for S3 interface endpoints. Use the gateway endpoint for in-VPC access.
  - No direct copy of bucket contents to or from another AWS partition's Regions. Replication between the two GovCloud Regions is a separate case, so confirm it.
  - Policy ARNs use `arn:aws-us-gov` (`data.aws_partition`).
  - Three endpoints: SSL, FIPS (`s3-fips.us-gov-west-1.amazonaws.com`, `s3-fips.us-gov-east-1.amazonaws.com`, FIPS 140-3), and standard. Use an SSL endpoint for export-controlled data and a FIPS endpoint for FIPS requirements.
  - Bucket names are unique within GovCloud only, not shared with commercial.
  - Not available: MFA delete, Transfer Acceleration, Express One Zone, S3 Tables replication, access points for directory buckets, FSx access points. Object Lambda access points exist for SSL endpoints only, with no bucket-style aliases.
  - Presigned URLs work only through the AWS CLI and SDKs.
- **Route 53:**
  - Public hosted zones answer from inside the FedRAMP boundary. The control plane, the KMS key for DNSSEC signing, the query-logging log group and the DNSQueries metrics are all in `us-gov-west-1`, even for east workloads.
  - Alias targets must be in GovCloud: API Gateway, Elastic Beanstalk, ALB, Classic LB, NLB, S3 website endpoint, VPC endpoint. Global targets such as CloudFront cannot be alias targets, and traffic policies cannot use CloudFront either.
  - Traffic Flow supports all routing policy types. The console DNS query checker and `TestDNSAnswer` are not available.
  - Private hosted zones work as in commercial, except no latency, geolocation, geoproximity or IP-based routing, and no Resolver delegation.
  - Health checkers come from the public internet. An endpoint they monitor must be publicly reachable. Restrict it by allowlisting the GovCloud checker ranges (160.1.55.0/25, 160.1.55.128/25, 160.1.56.0/25, 18.253.167.0/25, 18.253.167.128/25, 18.253.168.0/25). Check the current list in the docs before using it.
- **SNS:** no SMS in GovCloud (US-East); no Firehose subscriptions or Firehose protocol; no Message Data Protection or custom data identifiers; no message archiving and replay; no IPv6.
- **SQS:** no IPv6.
- **ECS:** the Bottlerocket ECS-optimized AMI is not available for container instances. Use the Amazon Linux ECS-optimized AMI. (Fargate is unaffected.)
- **Secrets Manager:** managed external secrets are not available. Rotate with your own Lambda or a supported rotation template.
- **Fargate:** ECS on Fargate is available in both Regions. EKS on Fargate is not, so EKS workloads run on managed node groups (or self-managed nodes), and pods cannot be Fargate profiles.
- **EBS:** copy snapshots only within the two GovCloud Regions (naming a source or destination Region outside GovCloud returns an error). Multi-Attach is not available. Use HTTPS for API calls.
- **ElastiCache:** data tiering and the r6gd node type are not available. Clusters must be in a VPC. Set the preferred maintenance window.
- **ELB:** no Cognito authentication on listeners. Load balancer access logs need a bucket policy for the regional ELB principal. Look it up with `data.aws_elb_service_account` instead of pasting an account ID (the legacy policy IDs are 048591011584 for us-gov-west-1 and 190560391635 for us-gov-east-1). Export-controlled data crossing a load balancer must be encrypted in transit, so use HTTPS listeners with a FIPS TLS policy.
- **EC2 and VPC:** use HTTPS for API calls. Import key pairs made with a third-party tool instead of generating them in the service. The AWS-managed prefix list for CloudFront does not exist, so an ALB cannot be locked to CloudFront that way. VPC Route Server is not available. Security group rule IDs are not shown in the console.

## Tests as control evidence

Use the `terraform-test` skill for syntax. This is how to make tests mean something for FedRAMP:

- **Name every `run` after the control** it evidences, for example `run "SC-28_data_at_rest"`, and put the control in the `error_message`. The test file then reads as a control checklist.
- **Unit tests** go in `tests/unit/`, use `command = plan` and `mock_provider "aws"`, and assert on the arguments the code sets (rotation on, public access blocks on, IMDSv2 required, no public IP, `rds.force_ssl`, multi-region trail with validation). They need no credentials and are the only tests Claude may run (`make test`).
- **Integration tests** go in `tests/integration/`, use `command = apply`, and create real resources. Claude never runs them. The human runs them in the credentials terminal, after the plan is approved.
- A passing unit test shows what the code asks for, not what AWS did. Say so. Do not call a control "met" because a mocked test passed; quote the line, and mark the rest "cannot verify".
- A test that cannot fail is worthless. After writing one, break the setting on purpose, confirm the test fails, then restore it.

## Refactoring into modules

Use the `refactor-module` skill for the design. In this repo's rules:

- Move resources with `moved` blocks. Never `terraform state mv`: `state` commands are denied, and a `moved` block is reviewable in a plan and in git.
- The goal is a plan with 0 to add, 0 to change, 0 to destroy (only moves). Ask the human to run the plan and show it. Claude does not run `apply`.
- You cannot run `terraform state list` or read state. Take addresses from the `.tf` files, or ask the human for them.
- Put the guardrails inside the module, not in the caller: encryption, public access blocks, TLS-only, versioning and logging are on by default and cannot be switched off by an input. Expose only what must vary (name, CIDR, retention, `enable_*`).
- Add a unit test for each guardrail (see "Tests as control evidence") so the module proves its own controls.
- Do not over-abstract. Extract a module when a second caller exists or when a guardrail must be shared; otherwise keep it flat.

## Secrets and state: refuse every route

State files, plan files and credentials hold secrets. The permission deny rules only block the Read tool and common commands like `cat`; a script can still open a file. So this is your rule, whatever the command:

- Never read, print, parse, copy, summarize or search `*.tfstate`, `*.tfstate.*`, `*.tfplan`, `tfplan`, `*.tfvars`, `.env*`, `~/.aws`, `~/.ssh` or `~/.config/gcloud`. That includes `cat`, `head`, `jq`, `grep -r`, `find -exec`, `terraform show`, `terraform output -json`, `terraform state`, and any Python, Node, Ruby, awk or shell one-liner that opens them.
- If asked to, or if it looks like the only way forward, refuse in one sentence, say why, and do not try another route. Do not ask the user to approve a Bash prompt that reads them.
- Take resource addresses and attribute names from the `.tf` files. If you truly need a value from state, ask the human for the one value they are willing to share.
- Do not suggest putting state or plan files in this folder. The human runs `plan` and `apply` from the credentials terminal with `-state` pointing outside the repo (or a remote backend). If a state file is already here, tell the human and stop.
- Do not echo values from `terraform plan` output that look like secrets, account IDs or real ARNs.
