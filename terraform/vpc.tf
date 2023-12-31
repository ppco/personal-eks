locals {
  project = var.project
}

resource "aws_vpc" "sample_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name      = "${local.project}-vpc"
    terraform = true
  }
}

resource "aws_subnet" "sample_public_subnet1" {
  vpc_id            = aws_vpc.sample_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name      = "${local.project}-public1"
    terraform = true
  }
}

resource "aws_subnet" "sample_public_subnet2" {
  vpc_id            = aws_vpc.sample_vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name      = "${local.project}-public2"
    terraform = true
  }
}

resource "aws_subnet" "sample_private_subnet1" {
  vpc_id            = aws_vpc.sample_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name      = "${local.project}-private1"
    terraform = true
  }
}

resource "aws_subnet" "sample_private_subnet2" {
  vpc_id            = aws_vpc.sample_vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name      = "${local.project}-private2"
    terraform = true
  }
}

resource "aws_internet_gateway" "sample_igw" {
  vpc_id = aws_vpc.sample_vpc.id
  tags = {
    Name      = "${local.project}-igw"
    terraform = true
  }
}

resource "aws_route_table" "sample_public_route_table" {
  vpc_id = aws_vpc.sample_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample_igw.id
  }

  tags = {
    Name      = "${local.project}-public-route"
    terraform = true
  }

}
resource "aws_main_route_table_association" "sample_main_route_table" {
  vpc_id         = aws_vpc.sample_vpc.id
  route_table_id = aws_route_table.sample_public_route_table.id
}
resource "aws_route_table_association" "sample_public_route_table_ass1" {
  subnet_id      = aws_subnet.sample_public_subnet1.id
  route_table_id = aws_route_table.sample_public_route_table.id
}
resource "aws_route_table_association" "sample_public_route_table_ass2" {
  subnet_id      = aws_subnet.sample_public_subnet2.id
  route_table_id = aws_route_table.sample_public_route_table.id
}

resource "aws_eip" "sample_eip1" {
  domain = "vpc"
  tags = {
    Name      = "${local.project}-eip1"
    terraform = true
  }
}
resource "aws_eip" "sample_eip2" {
  domain = "vpc"
  tags = {
    Name      = "${local.project}-eip2"
    terraform = true
  }
}


resource "aws_nat_gateway" "sample_nat_gw1" {
  allocation_id = aws_eip.sample_eip1.id
  subnet_id     = aws_subnet.sample_public_subnet1.id
  depends_on    = [aws_internet_gateway.sample_igw]
}
resource "aws_nat_gateway" "sample_nat_gw2" {
  allocation_id = aws_eip.sample_eip2.id
  subnet_id     = aws_subnet.sample_public_subnet2.id
  depends_on    = [aws_internet_gateway.sample_igw]
}

resource "aws_route_table" "sample_private_route_table1" {
  vpc_id = aws_vpc.sample_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sample_nat_gw1.id
  }

  tags = {
    Name      = "${local.project}-private-route1"
    terraform = true
  }

}

resource "aws_route_table" "sample_private_route_table2" {
  vpc_id = aws_vpc.sample_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sample_nat_gw2.id
  }

  tags = {
    Name      = "${local.project}-private-route2"
    terraform = true
  }

}

resource "aws_route_table_association" "sample_private_route_table_ass1" {
  subnet_id      = aws_subnet.sample_private_subnet1.id
  route_table_id = aws_route_table.sample_private_route_table1.id
}
resource "aws_route_table_association" "sample_private_route_table_ass2" {
  subnet_id      = aws_subnet.sample_private_subnet2.id
  route_table_id = aws_route_table.sample_private_route_table2.id
}