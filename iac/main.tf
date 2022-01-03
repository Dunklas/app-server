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
  ami                    = data.aws_ami.ubuntu.id
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
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKI/RAhuoRajVLgMPvTpKhLmmkykUfDFINPEOl4LKevX+dNfNao2Nc7u56CXHNX+Ps9DwTTIivMD/cFbcFwSLFwLWKvFPvaQrSDyFT6CERgJ6C7qaddQhPvCP1XJG7etMZu9H/l0XqcC/8Z7CRZhIxGXzL6xfLd9zU++nmFC/fkHFGhea9MqEMOXnU9inyYMmq7dX4u+WBLXfkMBjFYhmFOKjFsEwSc4n+wtVVxZrZdZ6R3K9ej4u6oPoqcmZwsBWo/fDQjhqn20Q8BCBl6Si6dXyevD3K9vidyB3vjthMczR+MFa/KexHY3kdUi+PSpAzMWAinTMGiY5qpdngeYWxDe4Ty74gsvrgM+D02pWJ361THPIbSn3Gdpj8Tx2meYi+pmZ2AK/I/wju9ce7++8F2KkMZ+rt15rV7vfUndlKhwKgwzRRFSiecWsVvm2U0iVKSnt71kmUZfuIacza404ldqjGv3GmzSlRD0rOIOpjPGJ1jsWJBERTcnEeGJdq9jM= rickard@dunkStation"
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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}