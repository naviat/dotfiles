---
name: terraform-gcp
description: Write, review or explain Terraform for Google Cloud. Use when the provider is google or google-beta, or the task mentions GCP, projects, VPC, GKE, Cloud Storage or Cloud KMS.
---

# Terraform on Google Cloud

- Scope is a project, not an account. Ask for the organization, folder and project layout, and the region.
- Authenticate with Application Default Credentials or service account impersonation. Never create or commit service account keys.
- State: GCS bucket with versioning, uniform bucket-level access, public access prevention, and CMEK if keys must be controlled. The backend supports locking.
- Encryption: Cloud KMS keys with a rotation period. Use CMEK on buckets, disks and databases when key control is required.
- Network: custom-mode VPC, no default network, private Google access on subnets, firewall rules by tag or service account, no `0.0.0.0/0` on admin ports. Use IAP TCP forwarding for admin access.
- IAM: least-privilege roles on named principals, no basic roles (owner, editor), dedicated service accounts instead of the default compute account.
- Audit: Cloud Audit Logs with Data Access logs enabled where sensitive, log sinks to a protected bucket, retention set.
- Org policy constraints (public IP, external sharing, allowed regions) are usually set above the project. Ask before adding them.

Work rules: smallest change per finding, run `make fmt validate lint scan`, never run `apply`, `destroy`, `import` or any `gcloud` command, never print credentials or project secrets. The human runs `plan`.

## Secrets and state: refuse every route

State files, plan files and credentials hold secrets. The permission deny rules only block the Read tool and common commands like `cat`; a script can still open a file. So this is your rule, whatever the command:

- Never read, print, parse, copy, summarize or search `*.tfstate`, `*.tfstate.*`, `*.tfplan`, `tfplan`, `*.tfvars`, `.env*`, `~/.aws`, `~/.ssh` or `~/.config/gcloud`. That includes `cat`, `head`, `jq`, `grep -r`, `find -exec`, `terraform show`, `terraform output -json`, `terraform state`, and any Python, Node, Ruby, awk or shell one-liner that opens them.
- If asked to, or if it looks like the only way forward, refuse in one sentence, say why, and do not try another route. Do not ask the user to approve a Bash prompt that reads them.
- Take resource addresses and attribute names from the `.tf` files. If you truly need a value from state, ask the human for the one value they are willing to share.
- Do not suggest putting state or plan files in this folder. The human runs `plan` and `apply` from the credentials terminal with `-state` pointing outside the repo (or a remote backend). If a state file is already here, tell the human and stop.
- Do not echo values from `terraform plan` output that look like secrets, account IDs or real ARNs.
