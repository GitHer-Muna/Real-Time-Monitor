# RDS MySQL Database (Optional - enable with var.enable_rds = true)

# Security group for RDS
resource "aws_security_group" "rds" {
  count = var.enable_rds ? 1 : 0

  name_prefix = "${var.project_name}-rds-"
  description = "Security group for RDS MySQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-rds-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# DB subnet group
resource "aws_db_subnet_group" "main" {
  count = var.enable_rds ? 1 : 0

  name       = "${var.project_name}-db-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-db-subnet"
    }
  )
}

# RDS MySQL instance
resource "aws_db_instance" "mysql" {
  count = var.enable_rds ? 1 : 0

  identifier     = "${var.project_name}-mysql"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password != "" ? var.db_password : random_password.db_password[0].result

  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]
  publicly_accessible    = false

  # Backup configuration
  backup_retention_period = var.environment == "prod" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # High availability for production
  multi_az = var.environment == "prod"

  # Performance insights
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.project_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-mysql"
    }
  )
}

# Generate random password if not provided
resource "random_password" "db_password" {
  count = var.enable_rds && var.db_password == "" ? 1 : 0

  length  = 16
  special = true
}

# Store database credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  count = var.enable_rds ? 1 : 0

  name_prefix = "${var.project_name}-db-credentials-"
  description = "RDS MySQL credentials for ${var.project_name}"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-db-credentials"
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  count = var.enable_rds ? 1 : 0

  secret_id = aws_secretsmanager_secret.db_credentials[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password != "" ? var.db_password : random_password.db_password[0].result
    endpoint = aws_db_instance.mysql[0].endpoint
    database = var.db_name
  })
}
