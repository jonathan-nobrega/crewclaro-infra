variable "name"        { type = string }
variable "cluster_id"  { type = string }
variable "image"       { type = string }
variable "cpu" {
  type    = number
  default = 256
}
variable "memory" {
  type    = number
  default = 512
}
variable "port" {
  type    = number
  default = null
}
variable "subnet_ids"  { type = list(string) }
variable "environment" {
  type    = map(string)
  default = {}
}
variable "desired" {
  type    = number
  default = 1
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions = jsonencode([{
    name         = var.name
    image        = var.image
    essential    = true
    portMappings = var.port == null ? [] : [{ containerPort = var.port }]
    environment  = [for k, v in var.environment : { name = k, value = v }]
    logConfiguration = {
      logDriver = "awslogs"
      options   = { awslogs-group = aws_cloudwatch_log_group.this.name, awslogs-region = "us-east-1", awslogs-stream-prefix = var.name }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired
  launch_type     = "FARGATE"
  network_configuration { subnets = var.subnet_ids }
}
