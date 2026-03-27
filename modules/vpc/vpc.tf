resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "my-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    map_public_ip_on_launch = var.map_public_ip_on_lanuch
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "my-igw"
    }
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "my-route-table"
    }

    route {
        gateway_id = aws_internet_gateway.igw.id
        cidr_block = "0.0.0.0/0"
    }
}

resource "aws_route_table_association" "rta" {
    route_table_id = aws_route_table.rt.id
    subnet_id = aws_subnet.public.id
}

resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.vpc.id
    name = "my-security-group"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "vpc" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    user_data = <<-EOF
       #!/bin/bash
       sudo -i
       yum update -y
       yum install httpd -y
       systemctl start httpd
       echo "Hello Terraform" > /var/www/html/index.html
       EOF
    tags = {
        Name = "vpc-server"
    }
}


