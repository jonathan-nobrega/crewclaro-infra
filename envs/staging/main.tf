provider "aws" { region = "us-east-1" }

variable "image_tag" { type = string }

locals {
  env  = "staging"
  name = "crewclaro-${local.env}"
}

module "network" {
  source = "../../modules/network"
  name   = local.name
}

resource "aws_ecs_cluster" "main" { name = local.name }

module "db" {
  source     = "../../modules/rds-postgres"
  name       = "${local.name}-db"
  subnet_ids = module.network.private_subnet_ids
  instance   = "db.t4g.micro"
}

module "redis" {
  source     = "../../modules/elasticache"
  name       = "${local.name}-redis"
  subnet_ids = module.network.private_subnet_ids
}

module "api" {
  source     = "../../modules/ecs-service"
  name       = "${local.name}-api"
  cluster_id = aws_ecs_cluster.main.id
  image      = "ghcr.io/jonathan-nobrega/crewclaro-api:${var.image_tag}"
  port       = 4000
  desired    = 1
  subnet_ids = module.network.private_subnet_ids
  environment = {
    REDIS_URL       = module.redis.redis_url
    SUPPORTED_LANGS = "en,es,pt,pl"
  }
}

module "translator" {
  source     = "../../modules/ecs-service"
  name       = "${local.name}-translator"
  cluster_id = aws_ecs_cluster.main.id
  image      = "ghcr.io/jonathan-nobrega/crewclaro-translator:${var.image_tag}"
  subnet_ids = module.network.private_subnet_ids
  environment = {
    REDIS_URL            = module.redis.redis_url
    TRANSLATION_PROVIDER = "llm"
  }
}

module "web" {
  source = "../../modules/s3-cdn"
  bucket = "${local.name}-web"
}

module "uploads" {
  source = "../../modules/s3-cdn"
  bucket = "${local.name}-uploads"
}
