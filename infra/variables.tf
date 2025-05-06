variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "key_name" {}
variable "private_key_path" {}
variable "aws_session_token" {}
variable "ec2_host" {
  description = "Public DNS or IP of the manually created EC2 instance"
  type        = string
}
