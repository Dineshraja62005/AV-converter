provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# Provision on an existing EC2 instance
resource "aws_instance" "av_ec2"{
  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = var.ec2_host                # <-- GitHub Secret value
    private_key = file(var.private_key_path)
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3-pip"
    ]
  }
}
