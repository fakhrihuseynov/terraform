data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-2-ami-hvm-*-x86_64-gp2"]
  }
}

# Deploy Amazon Linux WebServer
resource "aws_instance" "my-webserver" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.server_size
  vpc_security_group_ids = [aws_security_group.my-webserver.id]
  user_data              = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="black">
<h2><font color="gold"><font size=500px>Build by Power of DevOps Terraform <font color="white"> v0.13</font></h2><br><p>
<h2><font color="gold"><font size=300px>Designed by Fakhri Huseynov <font color="white"> v0.13</font></h2><br><p>
<font color="green">Server PrivateIP: <font color="aqua">$myip<br><br>

<font color="magenta">
<b>Version 2.0</b>
<body>
</html>
sudo service httpd start
chkconfig httpd on
EOF
  tags = {
    Name  = "${var.server_name}-WebServer"
    Owner = "Fakhri Huseynov"
  }
}

# Deploy Network Securty Group
resource "aws_security_group" "my-webserver" {
  name        = "${var.server_name}-WebServer-SG"
  description = "Allow TLS inbound traffic"

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.server_name}-WebServer Security Group"
    Owner = "Fakhri Huseynov"
  }
}

resource "aws_eip" "webPip" {
  instance = aws_instance.my-webserver.id
  tags = {
    Name  = "${var.server_name}-WebServer-IP"
    Owner = "Fakhri Huseynov"
  }
}
