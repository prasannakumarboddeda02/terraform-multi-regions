resource "aws_default_vpc" "vpc" {
  for_each = var.regions
  region = each.value.region
}

resource "aws_instance" "ec2_instance" {

for_each = var.regions
ami = each.value.ami

instance_type = var.type

region = each.value.region

iam_instance_profile = aws_iam_instance_profile.ec2instance.id

vpc_security_group_ids = [aws_security_group.web_sg[each.key].id]

user_data = file("./userdata.tpl")

key_name = aws_key_pair.my-key-pair[each.key].key_name

tags = {
    Name = "EC2_instance"
}


}

resource "aws_key_pair" "my-key-pair" {
    for_each = var.regions
    region = each.value.region
    public_key = file("./my-key.pub")
    key_name = "my-key-pair"
}


resource "null_resource" "remote_execute_cmd" {

    for_each = var.regions

    triggers = {
        instance = aws_instance.ec2_instance[each.key].id
    }
    
    provisioner "remote-exec" {
        inline = [ 
            "#!/bin/bash",
            "sudo dnf update -y",
            "sudo dnf install -y nginx",
            "sudo echo '<h1>Hello, welcome to the cloud hello</h1>' | sudo tee /usr/share/nginx/html/index.html",
            "sudo systemctl enable nginx",
            "sudo systemctl start nginx"
         ]
    }

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("./my-key")
      host = aws_instance.ec2_instance[each.key].public_ip
    }
}

/*resource "aws_eip" "elastic_ip" {
    for_each = var.regions
    region = each.value.region
    instance = aws_instance.ec2_instance[each.key].id
}*/

resource "aws_security_group" "web_sg" {

  for_each    = var.regions
  region = each.value.region
  name        = "web-sg"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = aws_default_vpc.vpc[each.key].id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    Name = "web-sg"
  }
}

resource "aws_iam_instance_profile" "ec2instance" {
  name = "IAMEC2Instance"
  role = var.EC2-IAM-profile
}
