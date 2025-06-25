variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
# RDS Variables
variable "mysql_database" {
  description = "Name of the MySQL database"
  type        = string
}

variable "mysql_user" {
  description = "MySQL database username"
  type        = string
}

variable "mysql_password" {
  description = "MySQL database password"
  type        = string
  sensitive   = true
}

variable "mysql_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}