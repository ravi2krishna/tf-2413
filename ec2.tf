# EC2 Public Server
resource "aws_instance" "ibm-web-server" {   
  ami           = "ami-03c983f9003cb9cd1" # Ubuntu AMI # Amazon Linux ami-0a283ac1aafe112d5
  instance_type = "t2.micro"
  subnet_id = aws_subnet.ibm-web-sn.id
  key_name = "730"
  vpc_security_group_ids = aws_security_group.ibm-web-sg.id

  tags = {
    Name = "ibm-web-server"
  }
}

