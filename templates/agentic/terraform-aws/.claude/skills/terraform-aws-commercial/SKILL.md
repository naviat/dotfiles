---
name: terraform-aws-commercial
description: Write, review or explain Terraform for commercial AWS (partition aws, standard regions). Use when the target is not GovCloud and there is no FedRAMP requirement stated, or when comparing commercial AWS against GovCloud.
---

# Terraform on commercial AWS

## Defaults and how they differ from GovCloud

- Partition is `aws`. Still build ARNs from `data.aws_partition.current.partition` so the module ports to GovCloud later.
- Region is an input variable with no hidden default. Ask which region.
- FIPS endpoints are optional. Enable `use_fips_endpoint` only if a compliance requirement says so.
- The newest services and features usually arrive here first. Check the provider and region docs before assuming a feature is also in GovCloud.
- AWS managed KMS keys and SSE-S3 are acceptable when there is no stated key-control requirement. Use a customer managed key when you need rotation control, key policies or cross-account use.

## Baseline for every change

- Encrypt at rest and in transit. S3: public access blocked, versioning on, TLS-only policy.
- Remote state in S3 with encryption and locking (`use_lockfile = true` on Terraform 1.10+).
- Private subnets for workloads. Prefer VPC endpoints over NAT for AWS APIs when traffic is high.
- Roles with short-lived credentials, scoped actions on named ARNs, no wildcards.
- IMDSv2 required on EC2. No `0.0.0.0/0` on admin ports. Prefer SSM Session Manager.
- CloudTrail multi-region with log file validation. Provider `default_tags` for ownership and cost.
- Cost matters here more than in a compliance exercise. Mention NAT gateways, cross-AZ traffic, KMS requests and data events as cost drivers.

## Network and security group rules

- Spread subnets, tasks and databases across three AZs (`az_count` variable, 2 or 3, validated, default 3). Size the minimum capacity so any two AZs carry peak load, because capacity must exist before an AZ fails. Interface endpoints bill per AZ, so build only the ones the enabled workloads call.
- Empty the default security group with `aws_default_security_group` and no rules, so nothing attaches to it by accident. Scanners flag it for this reason.
- Workload groups get no inbound rules unless something truly needs them. Endpoint and database groups accept traffic only from a referenced security group (`referenced_security_group_id`), never a CIDR, so the rule follows the workload when IPs change.
- Write rules as separate `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources, one per port and source. Do not use inline `ingress` and `egress` blocks, and do not use `aws_security_group_rule`. Separate rules avoid dependency cycles between groups that reference each other (for example ECS and the database).
- Security groups are the main control: stateful, attached to ENIs. Network ACLs are stateless and sit on subnets, so add them only as a coarse extra layer and remember they need return-traffic rules.
- Egress is explicit. Prefer HTTPS to the VPC endpoints over open egress. If a rule must be wide, say why in a comment.

## How to work

1. Read the existing code and state the region, account layout and backend you found.
2. Smallest change per finding. Show the diff.
3. Run `make fmt validate lint scan`.
4. Never run `apply`, `destroy`, `import`, `state` or any `aws` command. Propose and explain. The human runs `plan` where the credentials are.
5. Never print or ask for credentials or account IDs.
6. If the user mentions FedRAMP, GovCloud or FIPS, switch to the `terraform-aws-govcloud` skill.

## Secrets and state: refuse every route

State files, plan files and credentials hold secrets. The permission deny rules only block the Read tool and common commands like `cat`; a script can still open a file. So this is your rule, whatever the command:

- Never read, print, parse, copy, summarize or search `*.tfstate`, `*.tfstate.*`, `*.tfplan`, `tfplan`, `*.tfvars`, `.env*`, `~/.aws`, `~/.ssh` or `~/.config/gcloud`. That includes `cat`, `head`, `jq`, `grep -r`, `find -exec`, `terraform show`, `terraform output -json`, `terraform state`, and any Python, Node, Ruby, awk or shell one-liner that opens them.
- If asked to, or if it looks like the only way forward, refuse in one sentence, say why, and do not try another route. Do not ask the user to approve a Bash prompt that reads them.
- Take resource addresses and attribute names from the `.tf` files. If you truly need a value from state, ask the human for the one value they are willing to share.
- Do not suggest putting state or plan files in this folder. The human runs `plan` and `apply` from the credentials terminal with `-state` pointing outside the repo (or a remote backend). If a state file is already here, tell the human and stop.
- Do not echo values from `terraform plan` output that look like secrets, account IDs or real ARNs.
