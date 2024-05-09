# VPC 
resource "aws_vpc" "ecomm-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ecomm"
  }
}

# PUBLIC SUBNET
resource "aws_subnet" "ecomm-web-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ecomm-web-subnet"
  }
}

# PRIVATE SUBNET
resource "aws_subnet" "ecomm-data-sn" {
  vpc_id     = aws_vpc.ecomm-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ecomm-database-subnet"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "ecomm-igw" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-internet-gateway"
  }
}

# PUBLIC ROUTE TABLE
resource "aws_route_table" "ecomm-web-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecomm-igw.id
  }

  tags = {
    Name = "ecomm-web-route-table"
  }
}

# PUBLIC ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "ecomm-web-rt-association" {
  subnet_id      = aws_subnet.ecomm-web-sn.id
  route_table_id = aws_route_table.ecomm-web-rt.id
}

# PRIVATE ROUTE TABLE
resource "aws_route_table" "ecomm-data-rt" {
  vpc_id = aws_vpc.ecomm-vpc.id

  tags = {
    Name = "ecomm-database-route-table"
  }
}

# PRIVATE ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "ecomm-data-rt-association" {
  subnet_id      = aws_subnet.ecomm-data-sn.id
  route_table_id = aws_route_table.ecomm-data-rt.id
}

# PUBLIC NACL
resource "aws_network_acl" "ecomm-web-nacl" {
  vpc_id = aws_vpc.ecomm-vpc.id

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
    Name = "ecomm-web-nacl"
  }
}

# PUBLIC NACL ASSOCIATION
resource "aws_network_acl_association" "ecomm-web-nacl-association" {
  network_acl_id = aws_network_acl.ecomm-web-nacl.id
  subnet_id      = aws_subnet.ecomm-web-sn.id
}

# PRIVATE NACL
resource "aws_network_acl" "ecomm-data-nacl" {
  vpc_id = aws_vpc.ecomm-vpc.id

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
    Name = "ecomm-data-nacl"
  }
}

# PRIVATE NACL ASSOCIATION
resource "aws_network_acl_association" "ecomm-data-nacl-association" {
  network_acl_id = aws_network_acl.ecomm-data-nacl.id
  subnet_id      = aws_subnet.ecomm-data-sn.id
}

# PUBLIC SECUIRTY GROUP 
resource "aws_security_group" "ecomm-web-sg" {
    name = "ecomm-web-server-sg"
    description = "Allows Web Server Traffic"
    vpc_id = aws_vpc.ecomm-vpc.id
    
    tags = {
        Name = "ecomm-web-secuirty-group"
    }
}

# SSH TRAFFIC 
resource "aws_vpc_security_group_ingress_rule" "ecomm-web-ssh" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# HTTP TRAFFIC 
resource "aws_vpc_security_group_ingress_rule" "ecomm-http-ssh" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# OutBound Traffic Allow
resource "aws_vpc_security_group_egress_rule" "ecomm-outbound" {
  security_group_id = aws_security_group.ecomm-web-sg.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}