
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name        = format("%s-vpc", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr_a
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = format("%s-public-subnet-a", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr_b
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name        = format("%s-private-subnet-a", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_subnet" "subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidr_c
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name        = format("%s-private-subnet-c", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = format("%s-internet-gateway", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = format("%s-public-route", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name        = format("%s-private-route", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_route_table_association" "subnet_a_route_table_association" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "subnet_b_route_table_association" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name        = format("%s-eip", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}

resource "aws_nat_gateway" "main" {
  subnet_id     = aws_subnet.subnet_b.id
  allocation_id = aws_eip.eip.id

  tags = {
    Name        = format("%s-nat-gateway", var.environment)
    Environment = var.environment
    "Manage by" : "Terraform"
  }
}



