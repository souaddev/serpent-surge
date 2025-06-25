# Security Group for Game Server
resource "aws_security_group" "game_server_sg" {
  name        = "serpent-game-server-sg"
  description = "Security group for game server"
  vpc_id      = aws_vpc.serpent_vpc.id
  
  # SSH access
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "serpent-game-server-sg"
  }
}

# Security Group for Database
resource "aws_security_group" "database_sg" {
  name        = "serpent-database-sg"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.serpent_vpc.id

  # MySQL access only from game server security group
  ingress {
    description     = "MySQL from game servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    # security_groups = [aws_security_group.game_server_sg.id]
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere (temporarily for testing)
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "serpent-database-sg"
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "serpent-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.serpent_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "serpent-alb-sg"
  }
}