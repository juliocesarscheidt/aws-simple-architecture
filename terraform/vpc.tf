resource "aws_vpc" "vpc_0" {
  cidr_block = "10.0.0.0/16"

  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "vpc_0"
  }
}

######## GATEWAYS ########
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc_0.id

  tags = {
    Name = "internet_gw"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.0.id

  tags = {
    Name = "nat_gw"
  }

  depends_on = [aws_subnet.public_subnet]
}

######## PUBLIC NETWORK ########
resource "aws_subnet" "public_subnet" {
  count             = length(var.aws_azs)
  cidr_block        = cidrsubnet(aws_vpc.vpc_0.cidr_block, 8, count.index)                      # 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, ...
  availability_zone = [for az in var.aws_azs : format("%s%s", var.aws_region, az)][count.index] # e.g. ["sa-east-1a", "sa-east-1b", "sa-east-1c"]

  map_public_ip_on_launch = true

  vpc_id = aws_vpc.vpc_0.id

  tags = {
    Name = "public_subnet_${count.index}"
  }

  depends_on = [aws_vpc.vpc_0]
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc_0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = {
    Name = "public_route"
  }

  depends_on = [aws_internet_gateway.internet_gw]
}

resource "aws_route_table_association" "assoc_route_public" {
  count = length(var.aws_azs)

  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route.id

  depends_on = [aws_subnet.public_subnet, aws_route_table.public_route]
}

######## PRIVATE NETWORK ########
resource "aws_subnet" "private_subnet" {
  count             = length(var.aws_azs)
  cidr_block        = cidrsubnet(aws_vpc.vpc_0.cidr_block, 8, count.index + length(var.aws_azs)) # 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, ...
  availability_zone = [for az in var.aws_azs : format("%s%s", var.aws_region, az)][count.index]  # e.g. ["sa-east-1a", "sa-east-1b", "sa-east-1c"]

  map_public_ip_on_launch = false

  vpc_id = aws_vpc.vpc_0.id

  tags = {
    Name = "private_subnet_${count.index}"
  }

  depends_on = [aws_vpc.vpc_0]
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc_0.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private_route"
  }

  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_route_table_association" "assoc_route_private" {
  count = length(var.aws_azs)

  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route.id

  depends_on = [aws_subnet.private_subnet, aws_route_table.private_route]
}
