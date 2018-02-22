terraform {
  backend "s3" {
    bucket  = "thestate"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  count = 3
  ami = "ami-97785bed"
  instance_type = "t2.micro"
  key_name = "tkey"

  security_groups = [ "ssh-access" ]

  tags {
    Name = “iacode-webserver”
  }
}

resource "aws_security_group" "ssh-access" {
  name = "ssh-access"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["142.112.130.185/32"]
  }
}

resource “aws_secruity_group” “web-access” {
  name = “web-access”
  ingress {
	from_port = 0
	to_port = 0
	protocol = “tcp”
	cider_blocks = [“0.0.0.0/0”]
  }
}
