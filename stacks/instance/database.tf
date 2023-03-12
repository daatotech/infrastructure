resource "random_password" "db" {
  length  = 16
  special = false
}

resource "aws_security_group" "mongodb" {
  name   = "${local.identifier}-mongodb"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier              = local.identifier
  engine                          = "docdb"
  master_username                 = "daato"
  master_password                 = random_password.db.result
  backup_retention_period         = 30
  preferred_backup_window         = "07:00-09:00"
  skip_final_snapshot             = true
  vpc_security_group_ids          = [aws_security_group.mongodb.id]
  db_subnet_group_name            = module.vpc.database_subnet_group
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name
  final_snapshot_identifier       = "${local.identifier}-final-snapshot"
}

resource "aws_docdb_cluster_instance" "this" {
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = "db.t3.medium"
  count              = 1
  identifier         = local.identifier
}

resource "aws_docdb_cluster_parameter_group" "this" {
  family = "docdb4.0"
  name   = local.identifier

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_ssm_parameter" "db_credentials" {
  name  = "db-credentials"
  type  = "SecureString"
  value = jsonencode({
    username = aws_docdb_cluster.this.master_username
    password = aws_docdb_cluster.this.master_password
  })
}