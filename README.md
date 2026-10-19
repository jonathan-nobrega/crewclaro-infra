# crewclaro-infra

> **Hackathon demo repo.** Mock code for testing a multi-repo agent. Not affiliated with or endorsed by CrewClaro.

Terraform for CrewClaro on AWS.

## What it provisions
| Module | Resources | Used by |
|---|---|---|
| `network` | VPC, public/private subnets, NAT | everything |
| `ecs-service` | Fargate service + ALB target group + log group | `crewclaro-api`, `crewclaro-translator` |
| `rds-postgres` | Postgres 16, private subnets | `crewclaro-api` |
| `elasticache` | Redis 7 | `crewclaro-api`, `crewclaro-translator` |
| `s3-cdn` | S3 + CloudFront | `crewclaro-web` static site, photo uploads from `crewclaro-mobile` |

## Environments
- `envs/staging`
- `envs/prod`

```bash
cd envs/staging
terraform init
terraform plan -var="image_tag=$(git -C ../../../crewclaro-api rev-parse --short HEAD)"
```

CI runs `terraform plan` on every PR (`.github/workflows/terraform-plan.yml`).
