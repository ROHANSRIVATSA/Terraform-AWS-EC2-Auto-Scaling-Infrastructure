# VARIABLES - Configurable Parameters for Infrastructure

variable "AWS_REGION" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-west-2"
}

variable "AMI" {
  description = "Amazon Machine Image (AMI) IDs by region - Amazon Linux 2"
  type        = map(string)
  default = {
    us-west-2 = "ami-0d593311db5abb72b"
    us-east-1 = "ami-0c2a1acae6667e438"
  }
}

variable "INSTANCE_TYPE" {
  description = "EC2 instance type for ASG"
  type        = string
  default     = "t2.micro"
}

variable "PUBLIC_KEY_PATH" {
  description = "Path to your SSH public key for EC2 key pair (e.g., ~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/oregon-region-key-pair.pub"
}