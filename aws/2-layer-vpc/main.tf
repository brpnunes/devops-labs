resource "aws_vpc" "main" {

    cidr_block = "10.5.0.0/16"

    tags = {
        Name = "Main VPC"
    }
}

resource "aws_subnet" "subnet_public_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.5.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public 1a"
  }
}

resource "aws_subnet" "subnet_public_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.5.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public 1b"
  }
}

resource "aws_subnet" "subnet_private_1a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.5.11.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private 1a"
  }
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.5.12.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private 1b"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main Internet Gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Public route table"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat_ip_public_1a" {
  vpc      = true
  tags = {
    Name = "Elastic IP - NAT Gw (Public 1a)"
  }
}

resource "aws_eip" "nat_ip_public_1b" {
  vpc      = true
  tags = {
    Name = "Elastic IP - NAT Gw (Public 1b)"
  }
}

resource "aws_nat_gateway" "nat_gw_1a" {
  allocation_id = aws_eip.nat_ip_public_1a.id
  subnet_id     = aws_subnet.subnet_private_1a.id


  tags = {
    Name = "NAT Gw Public 1a"
  }
}

resource "aws_nat_gateway" "nat_gw_1b" {
  allocation_id = aws_eip.nat_ip_public_1b.id
  subnet_id     = aws_subnet.subnet_private_1b.id


  tags = {
    Name = "NAT Gw Public 1b"
  }
}

resource "aws_security_group" "internal_server_sg" {
  name        = "Internal Server Security Group"
  description = "Allow SSH inbound traffic from Bastion Host only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from Bastion Host"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id]
  }

  tags = {
    Name = "Internal Server"
  }
}


resource "aws_security_group" "bastion_host_sg" {
  name        = "Bastion Host Security Group"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from Internet"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Bastion Host"
  }
}


data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


resource "aws_instance" "bastion-host" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_public_1a.id

  security_groups = [aws_security_group.bastion_host_sg.id]

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "internal-server" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_private_1b.id

  security_groups = [aws_security_group.internal_server_sg.id]
  
  tags = {
    Name = "internal-server"
  }
}
