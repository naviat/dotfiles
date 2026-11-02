---
description: Map each Terraform resource to the NIST 800-53 control it supports
argument-hint: [file or directory, default is the whole repo]
---
Read the Terraform in $ARGUMENTS (the whole repo if empty). Do not edit anything.

Output a table with these columns: resource address, file:line, control (NIST 800-53 ID), what the code does for it, status.

Status is one of: met, partly met, missing, cannot verify from code. Use "cannot verify" when the answer depends on something outside the code, for example account-level GuardDuty. Quote the exact argument or line that supports every "met".

After the table, list the three gaps you would fix first and any finding that is over-engineering for this stack, with a reason. Check the partition, region, encryption and public exposure explicitly.
