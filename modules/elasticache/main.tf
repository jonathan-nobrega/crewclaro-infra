variable "name"       { type = string }
variable "subnet_ids" { type = list(string) }

resource "aws_elasticache_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_cluster" "this" {
  cluster_id        = var.name
  engine            = "redis"
  engine_version    = "7.1"
  node_type         = "cache.t4g.micro"
  num_cache_nodes   = 1
  subnet_group_name = aws_elasticache_subnet_group.this.name
}

output "redis_url" {
  value = "redis://${aws_elasticache_cluster.this.cache_nodes[0].address}:6379"
}
