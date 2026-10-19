# crewclaro-infra onboarding

Terraform that provisions CrewClaro's AWS infrastructure for staging and production. It runs the backend containers, the database, Redis and the static web hosting. There is no application code here.

## What it runs
| Module | Resources | Used by |
|---|---|---|
| `modules/network` | VPC, public/private subnets, NAT | everything |
| `modules/ecs-service` | Fargate service, ALB target group, log group | `crewclaro-api`, `crewclaro-translator` |
| `modules/rds-postgres` | Postgres 16 in private subnets | `crewclaro-api` |
| `modules/elasticache` | Redis 7 | `crewclaro-api`, `crewclaro-translator` |
| `modules/s3-cdn` | S3 + CloudFront | `crewclaro-web` static site, photo uploads from `crewclaro-mobile` |

## Environments
| | `envs/staging` | `envs/prod` |
|---|---|---|
| API tasks | 1 | 3 |
| DB instance | `db.t4g.micro` | `db.t4g.medium` |

Both run in `us-east-1` and pull images from `ghcr.io/jonathan-nobrega/crewclaro-api` and `ghcr.io/jonathan-nobrega/crewclaro-translator`.

## Run
```bash
cd envs/staging
terraform init
terraform plan -var="image_tag=$(git -C ../../../crewclaro-api rev-parse --short HEAD)"
```
`image_tag` is required. The example takes it from a sibling checkout of `crewclaro-api`.

## Gotchas
- CI runs `terraform plan` on every PR (`.github/workflows/terraform-plan.yml`). Read the plan output before merging.
- The API service only receives `REDIS_URL` and `SUPPORTED_LANGS`. `DATABASE_URL` is not wired from the `db` module yet, so the API can't reach Postgres when deployed.
- Prod and staging are separate copies of `main.tf`. A change to one usually needs the same change in the other.
