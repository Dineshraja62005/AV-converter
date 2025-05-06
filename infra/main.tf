# Provider configuration
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# Data source to reference an existing security group by name
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["av_converter_sg"]  # Name of the existing security group
  }
}

# EC2 instance resource using the existing security group
resource "aws_instance" "av_ec2" {
  ami           = "ami-0c2b8ca1dad447f8a" # Ubuntu 22.04 LTS (update as needed)
  instance_type = "t2.medium"
  key_name      = var.key_name

  tags = {
    Name = "av-converter"
  }

  # Use the existing security group found using the data source
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

# Outputs (optional)
output "instance_public_ip" {
  value = aws_instance.av_ec2.public_ip
}
