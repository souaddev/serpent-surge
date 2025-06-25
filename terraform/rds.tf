resource "aws_db_instance" "serpent_mysql_01" {
  identifier          = "serpent-mysql-${formatdate("YYYYMMDD", timestamp())}"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  
  db_name             = var.mysql_database
  username            = var.mysql_user
  password            = var.mysql_password

  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  publicly_accessible    = true
  skip_final_snapshot    = true

  parameter_group_name = "default.mysql8.0"

  tags = {
    Name        = "serpent-mysql"
    Environment = "Development"
    Project     = "serpent-surge"
  }
}

# RDS Subnet Group using existing VPC subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "serpent-rds-subnet-group"
  subnet_ids = [aws_subnet.database_subnet.id, aws_subnet.game_subnet_2.id]

  tags = {
    Name = "Serpent RDS subnet group"
  }
}

# Update parameter group for SSL only
resource "aws_db_parameter_group" "serpent_mysql_01" {
  name   = "serpent-mysql-params"
  family = "mysql8.0"

  parameter {
    name  = "require_secure_transport"
    value = "ON"
  }
}


resource "null_resource" "init_database" {
  depends_on = [aws_db_instance.serpent_mysql_01]

  provisioner "local-exec" {
    command = <<-EOT
      mysql --host=${split(":", aws_db_instance.serpent_mysql_01.endpoint)[0]} --port=${split(":", aws_db_instance.serpent_mysql_01.endpoint)[1]} --user=${var.mysql_user} --password=${var.mysql_password} --ssl-mode=PREFERRED -e "CREATE DATABASE IF NOT EXISTS ${var.mysql_database}; USE ${var.mysql_database}; CREATE TABLE IF NOT EXISTS scores (id INT AUTO_INCREMENT PRIMARY KEY, name TEXT NOT NULL, score INT NOT NULL, difficulty INT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
    EOT
  }
}
