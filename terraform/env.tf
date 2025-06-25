# # # Create .env file with RDS details
# # resource "local_file" "env_file" {
# #   depends_on = [aws_db_instance.serpent_mysql]
  
# #   content = <<-EOT
# #     # RDS Configuration
# #     MYSQL_HOST=${aws_db_instance.serpent_mysql.endpoint}
# #     MYSQL_DATABASE=${var.mysql_database}
# #     MYSQL_USER=${var.mysql_user}
# #     MYSQL_PASSWORD=${var.mysql_password}

# #     # Backend Configuration
# #     BACKEND_PORT=3000
# #     NODE_ENV=production

# #     # Frontend Configuration
# #     FRONTEND_PORT=80
# #   EOT
# #   filename = "../.env"
# # }
# resource "local_file" "env_file" {
#   depends_on = [aws_db_instance.serpent_mysql]
  
#   content = <<-EOT
#     # RDS Configuration
#     MYSQL_HOST=${split(":", aws_db_instance.serpent_mysql.endpoint)[0]}
#     MYSQL_PORT=${split(":", aws_db_instance.serpent_mysql.endpoint)[1]}
#     MYSQL_DATABASE=${var.mysql_database}
#     MYSQL_USER=${var.mysql_user}
#     MYSQL_PASSWORD=${var.mysql_password}

#     # Backend Configuration
#     BACKEND_PORT=3000
#     NODE_ENV=production

#     # Frontend Configuration
#     FRONTEND_PORT=80
#   EOT
#   filename = "../.env"
# }

resource "local_file" "env_file" {
  depends_on = [aws_db_instance.serpent_mysql_01]
  
  content = <<-EOT
    # RDS Configuration
    MYSQL_HOST=${split(":", aws_db_instance.serpent_mysql_01.endpoint)[0]}
    MYSQL_PORT=${split(":", aws_db_instance.serpent_mysql_01.endpoint)[1]}
    MYSQL_DATABASE=${var.mysql_database}
    MYSQL_USER=${var.mysql_user}
    MYSQL_PASSWORD=${var.mysql_password}

    # Backend Configuration
    BACKEND_PORT=3000
    NODE_ENV=production

    # Frontend Configuration
    FRONTEND_PORT=80
  EOT
  filename = "../.env"
}