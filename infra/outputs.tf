output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.av_ec2.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.av_ec2.public_dns
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.av_ec2.id
}

output "app_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.av_ec2.public_ip}:5000"
}