resource "aws_vpc" "main" {

    cidr_block = var.cidr

    tags = {
        env = var.tag_env
    }
}

data "aws_availability_zones" "az" {}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)

  vpc_id   = aws_vpc.main.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    env = var.tag_env,
    Name = "${var.public_subnet_prefix}${count.index}"
  }
}

resource "aws_subnet" "app_subnet" {
  count = length(var.app_subnets)

  vpc_id   = aws_vpc.main.id
  cidr_block = var.app_subnets[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]

  tags = {
    env = var.tag_env,
    Name = "${var.app_subnet_prefix}${count.index}"
  }
}

resource "aws_subnet" "db_subnet" {
  count = length(var.db_subnets)

  vpc_id   = aws_vpc.main.id
  cidr_block = var.db_subnets[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]

  tags = {
    env = var.tag_env,
    Name = "${var.db_subnet_prefix}${count.index}"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway",
    env = var.tag_env,
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Public Route Table",
    env = var.tag_env
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  count = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_public_ip" {
  count = length(var.public_subnets)
  vpc      = true
  tags = {
    Name = "Elastic IP - NAT Gateway",
    env = var.tag_env
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat_public_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "Public Nat Gateway - ${count.index}"
  }
}

resource "aws_route_table" "app_route_table" {
  count = length(var.app_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "App Route Table",
    env = var.tag_env
  }
}

resource "aws_route_table_association" "app_route_table_assoc" {
  count = length(var.app_subnets)

  subnet_id      = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_route_table[count.index].id
}

resource "aws_route_table" "db_route_table" {
  count = length(var.db_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "DB Route Table",
    env = var.tag_env
  }
}

resource "aws_route_table_association" "db_route_table_assoc" {
  count = length(var.db_subnets)

  subnet_id      = aws_subnet.db_subnet[count.index].id
  route_table_id = aws_route_table.db_route_table[count.index].id
}

