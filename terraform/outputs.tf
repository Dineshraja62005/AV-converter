output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = local.create_instance ? aws_instance.k8s_node[0].public_ip : (
    length(data.aws_instances.existing_k8s.ids) > 0 ? data.aws_instances.existing_k8s.public_ips[0] : "no_instance_found"
  )
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = local.create_instance ? aws_instance.k8s_node[0].public_dns : (
    length(data.aws_instances.existing_k8s.ids) > 0 ? data.aws_instances.existing_k8s.public_dns[0] : "no_instance_found"
  )
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = local.create_instance ? aws_instance.k8s_node[0].id : (
    length(data.aws_instances.existing_k8s.ids) > 0 ? data.aws_instances.existing_k8s.ids[0] : "no_instance_found"
  )
}

output "kubernetes_url" {
  description = "URL to access the Kubernetes application"
  value       = "http://${local.create_instance ? aws_instance.k8s_node[0].public_ip : (
    length(data.aws_instances.existing_k8s.ids) > 0 ? data.aws_instances.existing_k8s.public_ips[0] : "no_instance_found"
  )}:30080"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = local.sg_id
}