# VPC
resource "aws_vpc" "serpent_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "serpent-surge-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "game_subnet" {
  vpc_id                  = aws_vpc.serpent_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "serpent-game-subnet"
  }
}

# Subnet for ALB in other AZ
resource "aws_subnet" "game_subnet_2" {
  vpc_id            = aws_vpc.serpent_vpc.id
  cidr_block        = "10.0.3.0/24"  
  availability_zone = "us-east-1b"  

  map_public_ip_on_launch = true

  tags = {
    Name = "serpent-game-subnet-2"
  }
}



# Private Subnet
resource "aws_subnet" "database_subnet" {
  vpc_id            = aws_vpc.serpent_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true #added

  tags = {
    Name = "serpent-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "serpent_igw" {
  vpc_id = aws_vpc.serpent_vpc.id

  tags = {
    Name = "serpent-surge-igw"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "game_route" {
  vpc_id = aws_vpc.serpent_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.serpent_igw.id
  }

  tags = {
    Name = "serpent-game-route"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "game_route_assoc" {
  subnet_id      = aws_subnet.game_subnet.id
  route_table_id = aws_route_table.game_route.id
}

# Associate Public Route Table with ALB Subnet
resource "aws_route_table_association" "game_route_assoc_2" {
  subnet_id      = aws_subnet.game_subnet_2.id
  route_table_id = aws_route_table.game_route.id
}

#added
resource "aws_route_table_association" "database_route_assoc" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.game_route.id
}