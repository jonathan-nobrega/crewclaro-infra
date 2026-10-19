variable "name"       { type = string }
variable "subnet_ids" { type = list(string) }
variable "instance" {
  type    = string
  default = "db.t4g.micro"
}

resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  identifier                  = var.name
  engine                      = "postgres"
  engine_version              = "16.4"
  instance_class              = var.instance
  allocated_storage           = 20
  db_name                     = "crewclaro"
  username                    = "crewclaro"
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.this.name
  skip_final_snapshot         = true
}

output "endpoint" { value = aws_db_instance.this.endpoint }
