terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.70.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKI/RAhuoRajVLgMPvTpKhLmmkykUfDFINPEOl4LKevX+dNfNao2Nc7u56CXHNX+Ps9DwTTIivMD/cFbcFwSLFwLWKvFPvaQrSDyFT6CERgJ6C7qaddQhPvCP1XJG7etMZu9H/l0XqcC/8Z7CRZhIxGXzL6xfLd9zU++nmFC/fkHFGhea9MqEMOXnU9inyYMmq7dX4u+WBLXfkMBjFYhmFOKjFsEwSc4n+wtVVxZrZdZ6R3K9ej4u6oPoqcmZwsBWo/fDQjhqn20Q8BCBl6Si6dXyevD3K9vidyB3vjthMczR+MFa/KexHY3kdUi+PSpAzMWAinTMGiY5qpdngeYWxDe4Ty74gsvrgM+D02pWJ361THPIbSn3Gdpj8Tx2meYi+pmZ2AK/I/wju9ce7++8F2KkMZ+rt15rV7vfUndlKhwKgwzRRFSiecWsVvm2U0iVKSnt71kmUZfuIacza404ldqjGv3GmzSlRD0rOIOpjPGJ1jsWJBERTcnEeGJdq9jM= rickard@dunkStation"
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