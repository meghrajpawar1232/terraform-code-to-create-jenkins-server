resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "app-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block[0]
  availability_zone = var.avail_zone[0]
  tags = {
    Name = "${var.env_prefix}-app-subnet-1"
  }
}

resource "aws_subnet" "dbapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block[1]
  availability_zone = var.avail_zone[1]
  tags = {
    Name = "${var.env_prefix}-db-subnet-1"
  }
}


resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

  resource "aws_eip" "myapp-eip" {
  vpc = true
  tags = {
    Name = "${var.env_prefix}-eip"
  }
}
resource "aws_nat_gateway" "myapp-ng" {
  allocation_id = aws_eip.myapp-eip.id
  subnet_id     = aws_subnet.app-subnet-1.id

  tags = {
    Name = "${var.env_prefix}-ng"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "myapp-subnet-1" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.public-rtb.id
  
}

resource "aws_route_table" "private-rtb" {
   vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myapp-ng.id
  }
  tags = {
    Name = "${var.env_prefix}-private-rtb"
  }
}

resource "aws_route_table_association" "db-subnet-1" {
  subnet_id      = aws_subnet.dbapp-subnet-1.id
  route_table_id = aws_route_table.private-rtb.id
}


resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "${var.env_prefix}-default-sg"
  }
}