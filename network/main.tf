/* VPC */

resource "aws_vpc" "testvpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  
  tags = {
    Project = var.project_name
    Name = "test-vpc"
  }
}

/* Subnets */

/* Public Subnets */

resource "aws_subnet" "public" {
  count                   = length(var.subnets_cidr_public)
  vpc_id                  = aws_vpc.testvpc.id
  cidr_block              = element(var.subnets_cidr_public, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Project = var.project_name
    Name = "Public-Subnet-${count.index + 1}"
  }
}


/* Private Subnets */

resource "aws_subnet" "private" {
  count                   = length(var.subnets_cidr_private)
  vpc_id                  = aws_vpc.testvpc.id
  cidr_block              = element(var.subnets_cidr_private, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Project = var.project_name
    Name = "Private-Subnet-${count.index + 1}"
  }
}

/* Internet Gateway */

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.testvpc.id

  tags = {
    Project = var.project_name
    Name = "igw"
  }
}

/* Route Tables */

resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.testvpc.id

  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Project = var.project_name
    Name = "rtpublic"
  }
}

resource "aws_route_table_association" "publicsubassociation" {
  count          = length(var.subnets_cidr_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.testvpc.id
  count = length(var.subnets_cidr_private)

  route {
    nat_gateway_id = element(aws_nat_gateway.nat-gw.*.id, count.index) 
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Project = var.project_name
    Name = "rtprivate"
  }
}

resource "aws_route_table_association" "privatesubassociation" {
  count          = length(var.subnets_cidr_private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.rt-private.*.id, count.index)
}

/* Nat Gateway to allow database in private subnet access to the internet */

resource "aws_eip" "eip-nat-gw" {
  vpc = true
  count = length(var.subnets_cidr_public)
}

resource "aws_nat_gateway" "nat-gw" {
  count = length(var.subnets_cidr_public)
  allocation_id = element(aws_eip.eip-nat-gw.*.id, count.index) 
  subnet_id = element(aws_subnet.public.*.id, count.index)
  depends_on = [aws_internet_gateway.igw]
}