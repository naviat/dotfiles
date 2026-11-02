# Event-driven on AWS GovCloud (US): starting pattern

Use as the default proposal after the interview. Change only what the answers require. Verify every service in the chosen region (us-gov-west-1 or us-gov-east-1) before relying on it.

## Components

- Producers: internal apps, API Gateway as ingress, AWS service events.
- EventBridge rules route events to SQS queues (one queue per consumer type, each with a DLQ).
- ECS on Fargate workers in private subnets across 3 AZs (`az_count`), min tasks = AZ count, scale on backlog per task.
- Data tier private: RDS PostgreSQL (Multi-AZ, encrypted), DynamoDB or S3 as needed.
- VPC endpoints: S3 (gateway), SQS, ECR (api and dkr), CloudWatch Logs, Secrets Manager, KMS (interface). No NAT unless an external API needs it.
- Security and ops: CloudTrail (multi-region, validation, KMS), CloudWatch alarms, Config, GuardDuty, Security Hub where available.

## GovCloud differences to check

- EventBridge Pipes and API destinations are not available. Call external APIs from the ECS worker.
- API Gateway cannot be an EventBridge event-bus target. Use it only as ingress.
- CloudTrail Lake has gaps. Do not promise it.
- CloudFront cannot be a Route 53 alias in GovCloud. Edge is Route 53 alias to ALB with WAF.
- EKS on Fargate is not available. ECS on Fargate is.
- Fargate Spot, Aurora Global Database, RDS Proxy: verify before use.
- Service metadata can leave the region (queue names, tags, descriptions). Keep export-controlled data out of names, tags and log fields.
- Use FIPS endpoints (`use_fips_endpoint = true`) and `data.aws_partition.current.partition` in ARNs.
- Running in GovCloud does not make the workload FedRAMP authorized. Map controls to the authorization boundary.

## Reliability checklist

| Area | Default |
| --- | --- |
| Deploy | 3 AZs, health checks, deployment circuit breaker with rollback |
| Queue | visibility timeout above worker time, maxReceiveCount 3 to 5, DLQ alarm, controlled redrive |
| Delivery | at-least-once, so idempotent consumers |
| Scaling | target tracking on backlog per task, graceful SIGTERM, stopTimeout, scale-in protection |
| Secrets | Secrets Manager, rotation where supported |
| DR | state RTO and RPO, backup restore test, second region only if justified |
| Supply chain | image scan, pinned digests, approved registry |

## Likely first questions this pattern raises

Region, FedRAMP level, peak msgs per second and seconds per message, FIFO or not, external API calls, RDS or DynamoDB, second region, who needs console access.
