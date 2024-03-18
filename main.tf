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
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public subnet for eu-west-2a"
  }
}

/*********************************
*     public subnet2               *
**********************************/

resource "aws_subnet" "public-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public subnet for eu-west-2b"
  }
}

/*********************************
*     private subnet 1              *
**********************************/

resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private subnet for eu-west-2a"
  }
}

/*********************************
*     private subnet2               *
**********************************/

resource "aws_subnet" "private-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private subnet for eu-west-2b"
  }
}

/***********************************************
*           instance key pair                  *
************************************************/

resource "aws_key_pair" "webserver-demo-key" {
  key_name   = "demo-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDuNDjqNLmFDfpAfLyk0xJI/mnsQJY7CBxcAqMOHnEUkRjdVtwDCGDadnG77iZjI0sNpVXqkZacSaxx684xGdy0tWihuixP81Kn+Zsgdwi+Mx4WjPfgT2s27lba2kZhJC0pEr5hzHEJWNwX1aOvQjGzIGr+898y6gwp/DK3cggFEQ/jNBCS76NYUFODQGpR4Wiw9cOo1B1TiGe0UW3H183+h/q1Fv3yGvFm6J0iQC83soT5hcskmuoDbstJF/y5jd7ghcQB+v67C3IWuC9oKnq+mte0oRg7+G7NnGsv1S3yBQobs8AuazOTPUmmQ/q/ThSClqwPUTd3ajfAd2sqz73+04ZDO+oZJsdYUUTl+rPzH3Qsn645iD+NJhK+G9Y8Kq6NWs2x+C2ikIPof8QIL/GfOfAk4TNi5DwCNTnhEJthPug6Zw7MhsySNjR5B5lin2Pa9iAmKLQ5XTNDvLs+gNqeEVWoBoYvM78CEh4A7+Q2Q224DvMeKrpgiVqUdI02Ht0= abbey@TOWOBOLA"
}

/*******************************
*        ec2 instance1         *
********************************/
resource "aws_instance" "web-server1" {
  ami                         = "ami-09885f3ec1667cbfc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet1.id
  vpc_security_group_ids      = [aws_security_group.webserver-sg.id]
  key_name                    = aws_key_pair.webserver-demo-key.id
  associate_public_ip_address = true

  tags = {
    Name = "first web ec2"
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
  key_name                    = aws_key_pair.webserver-demo-key.id
  associate_public_ip_address = true

  tags = {
    Name = "second web ec2"
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
*        internet gateway         *
********************************/

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet gw"
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
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public-rt.id
}

/***********************************
*        route association 2        *
************************************/

resource "aws_route_table_association" "public-association-2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public-rt.id
}

/***********************************************
*       Application load balancer              *
***********************************************/

resource "aws_lb" "my-aws-alb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver-sg.id]
  subnets            = [aws_subnet.public-subnet1.id, aws_subnet.private-subnet2.id]
}

resource "aws_lb_target_group" "alb-target-grp" {
  name        = "alb-target-grp"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "my-aws-alb1" {
  target_group_arn = aws_lb_target_group.alb-target-grp.arn
  target_id        = aws_instance.web-server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my-aws-alb2" {
  target_group_arn = aws_lb_target_group.alb-target-grp.arn
  target_id        = aws_instance.web-server2.id
  port             = 80
}

resource "aws_lb_listener" "lb_lst" {
  load_balancer_arn = aws_lb.my-aws-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-grp.arn
  }
}


/**************************************
*      Database subnet group          *
**************************************/

resource "aws_db_subnet_group" "default-db-sg" {
  name       = "main"
  subnet_ids = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

/************************************
*     Database instance             *
************************************/

resource "aws_db_instance" "db-instance" {
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "admin"
  password               = "password"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default-db-sg.id
  vpc_security_group_ids = [aws_security_group.db-sg.id]
}

/**************************************************
*    Create a Security group for Database server  *
**************************************************/

resource "aws_security_group" "db-sg" {
  name        = "db_sg"
  description = "Allows inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
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