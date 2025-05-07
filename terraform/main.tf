provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# Generate random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Get default VPC info
data "aws_vpc" "default" {
  default = true
}

# Look for existing kubernetes-sg security group
data "aws_security_group" "existing_sg" {
  name = "kubernetes-sg"
  vpc_id = data.aws_vpc.default.id
}

# Get latest Ubuntu AMI
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

# Check for existing instances with our tag
data "aws_instances" "existing_k8s" {
  filter {
    name   = "tag:Name"
    values = ["kubernetes-node-*"]
  }
  
  filter {
    name   = "instance-state-name"
    values = ["running", "pending"]
  }
  
  depends_on = [random_id.suffix]
}

locals {
  create_instance = length(data.aws_instances.existing_k8s.ids) == 0
  sg_id = data.aws_security_group.existing_sg.id
}

# EC2 instance for Kubernetes - only create if it doesn't exist
resource "aws_instance" "k8s_node" {
  count                  = local.create_instance ? 1 : 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [local.sg_id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "kubernetes-node-${random_id.suffix.hex}"
    CreatedBy = "terraform"
    Project = "av-converter"
  }

  # User data script to install basic requirements
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common python3 python3-pip
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    apt-get install -y unzip
    unzip awscliv2.zip
    ./aws/install
  EOF

  # Wait for instance to be created and SSH to be available
  provisioner "remote-exec" {
    inline = ["echo 'SSH connection established'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      k8s_node_ip = local.create_instance ? aws_instance.k8s_node[0].public_ip : (
        length(data.aws_instances.existing_k8s.ids) > 0 ? data.aws_instances.existing_k8s.public_ips[0] : "127.0.0.1"
      )
    }
  )
  filename = "${path.module}/../ansible/inventory.ini"
}