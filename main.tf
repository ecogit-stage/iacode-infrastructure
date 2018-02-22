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

resource "aws_instance" "iaweb1" {
  ami = "ami-97785bed"
  instance_type = "t2.micro"
  key_name = "tkey"

  security_groups = [ "ssh-access", "web-access" ]

  tags {
    Name = "iacode-webserver"
  }
}

data "http" "getmylocalpubip" {
  url = "http://icanhazip.com"
}

resource "aws_security_group" "ssh-access" {
  name = "ssh-access"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.getmylocalpubip.body)}/32"]
  }
}

output "ip" {
  value = "${data.http.getmylocalpubip.body}"
}   

resource "aws_security_group" "web-access" {
  name = "web-access"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.getmylocalpubip.body)}/32"]
  }
}
