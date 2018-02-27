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
  #ami = "ami-97785bed"
  ami = "ami-5c01ea21"
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

# Configure security groups
resource "aws_security_group" "ssh-access" {
  name = "ssh-access"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.getmylocalpubip.body)}/32"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
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

# Setup DNS record for iacode.tech
resource "aws_eip" "ins" {
  instance = "${aws_instance.iaweb1.id}"
  vpc      = true
}

resource "aws_route53_zone" "primary" {

  name = "iacode.tech"
  delegation_set_id = "N2NIJ94W6U2VSN"
  comment = "Powered By IACODE.COM"
  force_destroy = true
}

resource "aws_route53_record" "site" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "site.iacode.tech"
  type    = "A"
  ttl     = "60"
  records = ["${aws_eip.ins.public_ip}"]
}

# output dynamically generated nameservers
output "nameserv" {
  value = "${aws_route53_zone.primary.name_servers}"
}

output "ip" {
  value = "${data.http.getmylocalpubip.body}"
}   
