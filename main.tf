/*********************************
*     create vpc                 *
**********************************/

resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    terraform = "true"
    Name      = "default vpc"
  }
}

/*********************************
*     public subnet1               *
**********************************/

resource "aws_subnet" "public-subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public subnet for eu-west-2a"
  }
}

/*********************************
*     public subnet2               *
**********************************/

resource "aws_subnet" "public-subnet2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public subnet for eu-west-2b"
  }
}

/*********************************
*     private subnet 1              *
**********************************/

resource "aws_subnet" "private-subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private subnet for eu-west-2a"
  }
}

/*********************************
*     private subnet2               *
**********************************/

resource "aws_subnet" "private-subnet2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private subnet for eu-west-2b"
  }
}

/*******************************
*        ec2 instance         *
********************************/
resource "aws_instance" "web-server1" {
  ami                         = "ami-09885f3ec1667cbfc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet1.id
  vpc_security_group_ids      = [aws_security_group.webserver-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "web ec2"
  }
}

/*******************************
*        ec2 instance2         *
********************************/
resource "aws_instance" "web-server2" {
  ami                         = "ami-09885f3ec1667cbfc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet2.id
  vpc_security_group_ids      = [aws_security_group.webserver-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "web ec2"
  }
}

/********************************************
*        webserver instance security group        *
*********************************************/

resource "aws_security_group" "webserver-sg" {
  name        = "web-sg"
  description = "allow inbound ssh and https traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*******************************
*        route table         *
********************************/

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "internet public route"
  }
}

/***********************************
*        route association 1         *
************************************/

resource "aws_route_table_association" "public-association-1" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

/***********************************
*        route association 2        *
************************************/

resource "aws_route_table_association" "public-association-2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt.id
}