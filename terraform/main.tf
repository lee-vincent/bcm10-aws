locals {
  name = var.project_name
  tags = {
    Project = var.project_name
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = "${local.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${local.name}-igw" })
}

# Public subnet
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.42.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = merge(local.tags, { Name = "${local.name}-public-a" })
}

# Private subnet (future use)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.42.1.0/24"
  availability_zone = "${var.region}a"
  tags = merge(local.tags, { Name = "${local.name}-private-a" })
}

# NAT (optional)
resource "aws_eip" "nat" {
  count = var.enable_egress_internet ? 1 : 0
  domain = "vpc"
  tags   = merge(local.tags, { Name = "${local.name}-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_egress_internet ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(local.tags, { Name = "${local.name}-nat" })
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${local.name}-public-rt" })
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${local.name}-private-rt" })
}

resource "aws_route" "private_out" {
  count                  = var.enable_egress_internet ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.enable_egress_internet ? aws_nat_gateway.nat[0].id : null
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

# Security Group for head node
resource "aws_security_group" "head_sg" {
  name        = "${local.name}-head-sg"
  description = "Head node access"
  vpc_id      = aws_vpc.main.id
  tags        = merge(local.tags, { Name = "${local.name}-head-sg" })

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Base View UI"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Optional web ports
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Head node EC2
resource "aws_instance" "head" {
  ami                         = var.head_ami_id
  instance_type               = var.head_instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.head_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = file("${path.module}/user_data.sh")

  tags = merge(local.tags, { Name = "${local.name}-head-1" })
}
