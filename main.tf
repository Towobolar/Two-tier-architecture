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

resource "aws_subnet" "private-subnet1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private subnet for eu-west-2b"
  }
}