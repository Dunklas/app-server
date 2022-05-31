terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0d19fa6f37a659a28"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.id
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id              = aws_subnet.subnet.id
}

resource "aws_route53_record" "dns_record" {
  for_each = toset(var.sub_domains)
  zone_id  = var.hosted_zone_id
  name     = each.value
  type     = "A"
  ttl      = "300"
  records  = [aws_eip.ip.public_ip]
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_pair_name
  public_key = var.key_pair_public_key
}

resource "aws_eip" "ip" {
  instance = aws_instance.app_server.id
  vpc      = true
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "sg" {
  name   = "app-server-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "eu-west-2a"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
