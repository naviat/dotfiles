# Project notes for agents

Before writing or reviewing any Terraform, read `.claude/skills/terraform-aws-commercial/SKILL.md` and follow it (Claude Code also loads it as the `terraform-aws-commercial` skill).

For style and tests, use the `terraform-style-guide` skill when writing HCL and the `terraform-test` skill for `.tftest.hcl` files (both from HashiCorp, pinned in `.claude/skills/*/SOURCE.txt`). To turn flat code into a reusable module, use the `refactor-module` skill with `moved` blocks, never `terraform state mv`.

When the brief is short or the architecture is unknown, use the `requirements-interview` skill first: ask the human one question at a time, record answers in `REQUIREMENTS.md`, propose the architecture, and write no Terraform until they say "go".

Terraform for commercial AWS. Region: <region>. No FedRAMP requirement unless stated.

## Commands

- `make fmt validate lint scan` after every small change (tflint, checkov, trivy).
- `terraform plan` needs credentials and is run by the human in a separate terminal.

## Rules

- Never print, write or ask for AWS credentials, session tokens or account IDs.
- Build ARNs from `data.aws_partition.current.partition`, never hardcode `arn:aws:`.
- Encrypt at rest and in transit, block public S3 access, no `0.0.0.0/0` on admin ports, IMDSv2 required, least-privilege IAM with no wildcards.
- Never run `terraform apply`, `destroy`, `import`, `state`, or any `aws` command. Propose it and explain what it changes.
- Never read state, plan, `.tfvars` or `.env` files by any route (cat, jq, grep, Python, `terraform show`). Refuse and do not retry another way. The skill explains why. State stays outside this folder (`-state` elsewhere or a remote backend).
- Smallest change per finding. Explain it by pointing at the file and line.
- Do not claim compliance you have not verified in the code. Quote the line.

Skill for this stack: `.claude/skills/terraform-aws-commercial` (loads when relevant).

## Deliberate decisions

<intentional choices agents must not revert>

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Prefer rewriting or pruning existing entries over appending new ones.
