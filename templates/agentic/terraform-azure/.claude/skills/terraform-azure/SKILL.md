---
name: terraform-azure
description: Write, review or explain Terraform for Microsoft Azure. Use when the provider is azurerm or azapi, or the task mentions Azure, subscriptions, resource groups, VNets, Key Vault or Storage accounts.
---

# Terraform on Azure

- Scope is tenant, subscription and resource group. Ask which subscription and region, and whether a landing zone already exists.
- Authenticate with OIDC or a managed identity. Never commit client secrets.
- State: Storage account container with versioning, soft delete, TLS 1.2 minimum, no public blob access, and Entra authentication. The azurerm backend locks with blob leases.
- Encryption: Key Vault with purge protection and soft delete, RBAC authorization, keys with a rotation policy. Use customer managed keys on storage and disks when key control is required.
- Network: VNet with private subnets, private endpoints for PaaS, NSGs with deny-by-default, no `*` source on admin ports. Prefer Bastion for admin access.
- Identity: managed identities for workloads, role assignments at the narrowest scope, no Owner or Contributor on a subscription for a workload.
- Audit: diagnostic settings to Log Analytics on each resource, activity log export, retention set. Azure Policy is usually assigned above the resource group, so ask first.

Work rules: smallest change per finding, run `make fmt validate lint scan`, never run `apply`, `destroy`, `import` or any `az` command, never print credentials or subscription secrets. The human runs `plan`.

## Secrets and state: refuse every route

State files, plan files and credentials hold secrets. The permission deny rules only block the Read tool and common commands like `cat`; a script can still open a file. So this is your rule, whatever the command:

- Never read, print, parse, copy, summarize or search `*.tfstate`, `*.tfstate.*`, `*.tfplan`, `tfplan`, `*.tfvars`, `.env*`, `~/.aws`, `~/.ssh` or `~/.config/gcloud`. That includes `cat`, `head`, `jq`, `grep -r`, `find -exec`, `terraform show`, `terraform output -json`, `terraform state`, and any Python, Node, Ruby, awk or shell one-liner that opens them.
- If asked to, or if it looks like the only way forward, refuse in one sentence, say why, and do not try another route. Do not ask the user to approve a Bash prompt that reads them.
- Take resource addresses and attribute names from the `.tf` files. If you truly need a value from state, ask the human for the one value they are willing to share.
- Do not suggest putting state or plan files in this folder. The human runs `plan` and `apply` from the credentials terminal with `-state` pointing outside the repo (or a remote backend). If a state file is already here, tell the human and stop.
- Do not echo values from `terraform plan` output that look like secrets, account IDs or real ARNs.
