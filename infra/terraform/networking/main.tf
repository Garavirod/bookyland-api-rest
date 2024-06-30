variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "cidr_private_subnet" {}
variable "us_availability_zone" {}

#######
# VPC #
#######
resource "aws_vpc" "bookyland_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

###########
# SUBNETS #
###########
resource "aws_subnet" "bookyland_public_subnets" {
  count = length(var.cidr_public_subnet)
  vpc_id = aws_vpc.bookyland_vpc.id
  cidr_block = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.us_availability_zone, count.index)
  tags = {
    Name = "bookyland-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "bookyland_private_subnets" {
  count = length(var.cidr_private_subnet)
  vpc_id = aws_vpc.bookyland_vpc.id
  cidr_block = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.us_availability_zone, count.index)
  tags = {
    Name = "bookyland-private-subnet-${count.index + 1}"
  }
}


####################
# INTERNET GATEWAY #
####################
resource "aws_internet_gateway" "bookyland_internet_gateway" {
  vpc_id = aws_vpc.bookyland_vpc.id
  tags = {
    Name = "dev-bookyland-IG"
  }
}


################
# ROUTE TABLES #
################
resource "aws_route_table" "bookyland_public_route_table" {
  vpc_id = aws_vpc.bookyland_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bookyland_internet_gateway.id
  }
  tags = {
    Name = "dev-bookyland-public-rt"
  }
}

resource "aws_route_table" "bookyland_private_route_table" {
  vpc_id = aws_vpc.bookyland_vpc.id
  tags = {
    Name = "dev-bookyland-private-rt"
  }
}

resource "aws_route_table_association" "public_rt_public_subnet_association" {
  count = length(aws_subnet.bookyland_public_subnets)
  subnet_id = aws_subnet.bookyland_public_subnets[count.index].id
  route_table_id = aws_route_table.bookyland_public_route_table.id
}

resource "aws_route_table_association" "private_rt_private_subnet_association" {
  count = length(aws_subnet.bookyland_private_subnets)
  subnet_id = aws_subnet.bookyland_private_subnets[count.index].id
  route_table_id = aws_route_table.bookyland_private_route_table.id
}

