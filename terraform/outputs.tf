output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.k8s_node.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.k8s_node.public_dns
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.k8s_node.id
}

output "kubernetes_url" {
  description = "URL to access the Kubernetes application"
  value       = "http://${aws_instance.k8s_node.public_ip}:30080"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.k8s_sg.id
}