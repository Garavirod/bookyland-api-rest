#######
# VPC #
#######
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

###########
# SUBNETS #
###########
resource "aws_subnet" "bookyland_private_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = false
}
resource "aws_subnet" "bookyland_public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
  map_public_ip_on_launch = true
}




####################
# INTERNET GATEWAY #
####################
resource "aws_internet_gateway" "bookyland_internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "dev-bookyland-IG"
  }
}


################
# ROUTE TABLES #
################
resource "aws_route_table" "bookyland_public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bookyland_internet_gateway.id
  }
  tags = {
    Name = "dev-bookyland-public-rt"
  }
}

resource "aws_route_table" "bookyland_private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "dev-bookyland-private-rt"
  }
}

resource "aws_route_table_association" "public_rt_public_subnet_association" {
  count          = length(aws_subnet.bookyland_public_subnets)
  subnet_id      = aws_subnet.bookyland_public_subnets[count.index].id
  route_table_id = aws_route_table.bookyland_public_route_table.id
}

resource "aws_route_table_association" "private_rt_private_subnet_association" {
  count          = length(aws_subnet.bookyland_private_subnets)
  subnet_id      = aws_subnet.bookyland_private_subnets[count.index].id
  route_table_id = aws_route_table.bookyland_private_route_table.id
}

