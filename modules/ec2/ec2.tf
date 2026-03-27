resource "aws_instance" "vm" {
  ami           = var.ami_id
  instance_type = var.inst_type
  key_name      = var.key_pair
  user_data     = <<-EOF
     #!/bin/bash
     sudo -i
     yum install httpd -y
     systemctl start httpd
     echo "Hello Terraform" > /var/www/html/index.html
    EOF
  tags = {
    Name = "TF-Server"
  }
}
