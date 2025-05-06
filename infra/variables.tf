variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_session_token" {
  description = "AWS Session Token"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}

variable "private_key_path" {
  description = "Path to SSH private key file"
  type        = string
}

variable "ec2_host" {
  description = "Public DNS or IP of the EC2 instance"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}