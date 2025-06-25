output "webserver_public_ips" {
  description = "Public IP addresses of the EC2 instances"
  value       = aws_instance.serpent_surge[*].public_ip
  sensitive   = false
}

output "webserver_public_dns" {
  description = "Public DNS of the EC2 instances"
  value       = aws_instance.serpent_surge[*].public_dns
  sensitive   = false
}


# Output the nameservers for verification
output "nameservers" {
  value = data.aws_route53_zone.epooz_hosted_zone.name_servers
  description = "Nameservers for domain verification"
}


output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.serpent_mysql_01.endpoint
  sensitive   = false
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.serpent_mysql_01.port
  sensitive   = false
}

output "database_connection_command" {
  value       = "mysql -h ${split(":", aws_db_instance.serpent_mysql_01.endpoint)[0]} -P ${split(":", aws_db_instance.serpent_mysql_01.endpoint)[1]} -u ${var.mysql_user} -p${var.mysql_password} ${var.mysql_database}"
  sensitive   = true
}

output "backend_security_group_id" {
  value = aws_security_group.game_server_sg.id
}

# output "rds_security_group_id" {
#   value = aws_security_group.rds_sg.id
# }