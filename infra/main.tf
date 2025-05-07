provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# Get default VPC info
data "aws_vpc" "default" {
  default = true
}

# Get Ubuntu AMI (explicitly specified)
data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  owners = ["099720109477"] # Canonical
}

data "aws_security_group" "existing_sg" {
  name = "av_converter_sg"
}

# EC2 instance - explicitly using Ubuntu
resource "aws_instance" "av_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "av-converter-ubuntu"
    Environment = "production"
    Project     = "video-to-audio-converter"
    OS          = "Ubuntu"
  }

  # Ensure we have Python for Ansible
  provisioner "remote-exec" {
    inline = [
      "echo 'Verifying Ubuntu installation...'",
      "cat /etc/os-release",
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip git curl"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  # Ubuntu uses 'ubuntu' as the default user
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

