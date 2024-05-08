# VPC 
resource "aws_vpc" "ibm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ibm"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "ibm-web-sn" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ibm-web-subnet"
  }
}

# PRIVATE SUBNET
resource "aws_subnet" "ibm-data-sn" {
  vpc_id     = aws_vpc.ibm-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ibm-database-subnet"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "ibm-igw" {
  vpc_id = aws_vpc.ibm-vpc.id

  tags = {
    Name = "ibm-internet-gateway"
  }
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "ibm-web-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ibm-igw.id
  }

  tags = {
    Name = "ibm-web-route-table"
  }
}

# PUBLIC ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "ibm-web-rt-association" {
  subnet_id      = aws_subnet.ibm-web-sn.id
  route_table_id = aws_route_table.ibm-web-rt.id
}

# PRIVATE ROUTE TABLE
resource "aws_route_table" "ibm-data-rt" {
  vpc_id = aws_vpc.ibm-vpc.id

  tags = {
    Name = "ibm-database-route-table"
  }
}

# PRIVATE ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "ibm-data-rt-association" {
  subnet_id      = aws_subnet.ibm-data-sn.id
  route_table_id = aws_route_table.ibm-data-rt.id
}

# PUBLIC NACL
resource "aws_network_acl" "ibm-web-nacl" {
  vpc_id = aws_vpc.ibm-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ibm-web-nacl"
  }
}

# PUBLIC NACL ASSOCIATION
resource "aws_network_acl_association" "ibm-web-nacl-association" {
  network_acl_id = aws_network_acl.ibm-web-nacl.id
  subnet_id      = aws_subnet.ibm-web-sn.id
}

# PRIVATE NACL
resource "aws_network_acl" "ibm-data-nacl" {
  vpc_id = aws_vpc.ibm-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ibm-data-nacl"
  }
}

# PRIVATE NACL ASSOCIATION
resource "aws_network_acl_association" "ibm-data-nacl-association" {
  network_acl_id = aws_network_acl.ibm-data-nacl.id
  subnet_id      = aws_subnet.ibm-data-sn.id
}

# PUBLIC SECUIRTY GROUP 
resource "aws_security_group" "ibm-web-sg" {
    name = "ibm-web-server-sg"
    description = "Allows Web Server Traffic"
    vpc_id = aws_vpc.ibm-vpc.id
    
    tags = {
        Name = "ibm-web-secuirty-group"
    }
}

# SSH TRAFFIC 
resource "aws_vpc_security_group_ingress_rule" "ibm-web-ssh" {
  security_group_id = aws_security_group.ibm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# HTTP TRAFFIC 
resource "aws_vpc_security_group_ingress_rule" "ibm-http-ssh" {
  security_group_id = aws_security_group.ibm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}