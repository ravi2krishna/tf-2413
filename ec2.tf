# EC2 Public Server
resource "aws_instance" "ecomm-web-server" {   
  ami           = "ami-03c983f9003cb9cd1" # Ubuntu AMI # Amazon Linux ami-0a283ac1aafe112d5
  instance_type = "t2.micro"
  subnet_id = aws_subnet.ecomm-web-sn.id
  key_name = "730"
  vpc_security_group_ids = [aws_security_group.ecomm-web-sg.id]
  user_data = file("ecomm.sh")

  tags = {
    Name = "ecomm-web-server"
  }
}

