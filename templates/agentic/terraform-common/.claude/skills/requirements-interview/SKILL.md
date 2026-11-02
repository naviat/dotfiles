---
name: requirements-interview
description: Use when the task is a short or vague brief ("build an event-driven architecture on ...") and the architecture is not known yet. Interview the human one question at a time, record answers in REQUIREMENTS.md, then propose the architecture before writing any Terraform.
---

# Requirements interview

Use this before any Terraform when the brief is short. Do not guess the architecture. Do not write `.tf` files until the human says "go".

## Rules

- Ask ONE question at a time. Wait for the answer. Never send a list of questions.
- Every question has: why it matters (one line), 2 to 4 options, and your recommended default marked "(default)". The human can answer with a single letter or "default".
- If the answer is "I don't know" or "ask the interviewer", write it as an open question and continue with the default. Mark it `ASSUMED` in `REQUIREMENTS.md`.
- Keep going until the ordered topics below are answered or assumed. Skip a topic if an earlier answer makes it moot, and say why.
- After each answer, append one line to `REQUIREMENTS.md` (create it if missing). Never put credentials, account IDs, real ARNs or tfvars values in it.
- Never run `aws`, `apply`, `destroy`, `import` or `state`. Questions are about the design, not the live account.

## Topics, in this order

1. Goal and trigger: what event starts the work, who produces it, what is the expected output.
2. Compliance and partition: FedRAMP Low, Moderate or High, any ITAR/CUI/DoD IL, GovCloud region (west, east, both).
3. Workload shape: async queue workers, sync API plus background jobs, scheduled or bursty batch.
4. Compute: ECS Fargate, ECS on EC2, Lambda, EKS. Container image source and registry.
5. Event routing: EventBridge, SNS fanout, SQS direct. Ordering (FIFO) and exactly-once needs, idempotency.
6. Volume and latency: peak and average messages per second, seconds per message, acceptable wait, spikes.
7. Data: stores needed (RDS PostgreSQL, DynamoDB, S3), size, retention, backups.
8. Availability and DR: number of AZs, RTO, RPO, second region needed or not.
9. Network and egress: private only, VPC endpoints, any outbound internet, external APIs, inbound ingress (ALB, API Gateway) and WAF.
10. Security: KMS customer keys, secrets, IAM boundaries, human access, TLS and FIPS endpoints.
11. Audit and monitoring: CloudTrail, Config, GuardDuty, Security Hub, alarms, dashboards, log retention.
12. Delivery: Terraform only or also CI/CD, state backend, environments, module layout, test expectations.
13. Constraints: time box, cost ceiling, things that must or must not be used, what the demo must show.

## Question format

```
Q4 of 13 - Compute
Why: decides scaling, networking and which IAM roles exist.
 a) ECS Fargate (default) - no servers, good fit for queue workers
 b) ECS on EC2 - needed for GPUs or host control
 c) Lambda - short jobs under 15 minutes
 d) EKS - only if Kubernetes is required
Answer a-d, "default", or your own words.
```

## When all topics are done

1. Print a short summary table: topic, answer, ASSUMED or confirmed.
2. List the open questions the human should confirm with the interviewer.
3. Propose the architecture in 8 lines or fewer: components, data flow, AZs, what is NOT included and why. If `references/` has a pattern for this workload, start from it and say which parts you changed.
4. Name the Terraform file layout (one file per concern) and the tests you will write first.
5. Ask "go?" Only after yes, write Terraform, following the cloud skill and `make fmt validate lint scan`.

## Handling changes mid-build

If a new requirement arrives, add it to `REQUIREMENTS.md`, say which files it touches, make the smallest change, and re-run the checks. Do not redesign.
