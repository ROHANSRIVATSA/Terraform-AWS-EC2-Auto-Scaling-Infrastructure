# MAIN CONFIGURATION - Provider & AWS Region Setup

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment below for remote state management with S3 backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "asg-infrastructure/terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      Project     = "Terraform-ASG-Infrastructure"
      Environment = "Development"
      ManagedBy   = "Terraform"
    }
  }
}


# VPC & NETWORKING RESOURCES

resource "aws_vpc" "dev-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "dev-subnet-public-1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "dev-subnet-public-1"
  }

  depends_on = [aws_vpc.dev-vpc]
}

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-igw"
  }

  depends_on = [aws_vpc.dev-vpc]
}

resource "aws_route_table" "dev-public-crt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "dev-public-crt"
  }

  depends_on = [aws_internet_gateway.dev-igw]
}

resource "aws_route_table_association" "dev-crta-public-subnet-1" {
  subnet_id      = aws_subnet.dev-subnet-public-1.id
  route_table_id = aws_route_table.dev-public-crt.id
}


# SECURITY GROUP - SSH & HTTP Access

resource "aws_security_group" "ssh-allowed" {
  name_prefix = "ssh-http-sg-"
  description = "Security group for SSH and HTTP access"
  vpc_id      = aws_vpc.dev-vpc.id

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: SSH (Port 22) - IMPORTANT: (Restrict this in production!)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access - restrict to your IP in production"
  }

  # Ingress: HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # Ingress: HTTPS (Port 443) - for future use
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  tags = {
    Name = "ssh-http-security-group"
  }

  depends_on = [aws_vpc.dev-vpc]
}


# KEY PAIR - SSH Access to Instances

resource "aws_key_pair" "oregon-region-key-pair" {
  key_name   = "oregon-region-key-pair"
  public_key = file(var.PUBLIC_KEY_PATH)

  tags = {
    Name = "oregon-region-key"
  }
}


# LAUNCH TEMPLATE - Instance Configuration Blueprint

resource "aws_launch_template" "dev-launch-config" {
  name_prefix   = "prod-launch-template-"
  image_id      = lookup(var.AMI, var.AWS_REGION)
  instance_type = var.INSTANCE_TYPE
  key_name      = aws_key_pair.oregon-region-key-pair.key_name

  vpc_security_group_ids = [aws_security_group.ssh-allowed.id]

  # User data script to bootstrap instances with Apache
  user_data = filebase64("${path.module}/userdata.sh")

  # Enable detailed monitoring (optional, has CloudWatch cost implications)
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "dev-asg-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "dev-asg-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


# AUTO SCALING GROUP - Dynamic Instance Management

resource "aws_autoscaling_group" "dev-autoscaling-group-3" {
  name                = "dev-asg-3"
  vpc_zone_identifier = [aws_subnet.dev-subnet-public-1.id]

  # Capacity configuration for proper auto-scaling
  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  # Health check configuration for enterprise reliability
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Launch template configuration
  launch_template {
    id      = aws_launch_template.dev-launch-config.id
    version = "$Latest"
  }

  # Lifecycle management
  termination_policies = ["OldestInstance"]

  # Wait for instances to be healthy before marking as complete
  wait_for_capacity_timeout = "5m"

  # Tags propagation to instances
  tag {
    key                 = "Name"
    value               = "dev-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "ASGName"
    value               = "dev-asg-3"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Development"
    propagate_at_launch = true
  }

  # Lifecycle rule to prevent unwanted termination
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_subnet.dev-subnet-public-1,
    aws_launch_template.dev-launch-config,
    aws_internet_gateway.dev-igw
  ]
}


# AUTO SCALING POLICIES - Dynamic Scaling Based on CPU Utilization
# Scale-up policy: Add instances when CPU > 70%
resource "aws_autoscaling_policy" "scale-up" {
  name                   = "dev-asg-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.dev-autoscaling-group-3.name
}

# CloudWatch alarm for scale-up
resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name          = "dev-asg-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU exceeds 70%"
  alarm_actions       = [aws_autoscaling_policy.scale-up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dev-autoscaling-group-3.name
  }
}

# Scale-down policy: Remove instances when CPU < 30%
resource "aws_autoscaling_policy" "scale-down" {
  name                   = "dev-asg-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.dev-autoscaling-group-3.name
}

# CloudWatch alarm for scale-down
resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name          = "dev-asg-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Alarm when CPU drops below 30%"
  alarm_actions       = [aws_autoscaling_policy.scale-down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dev-autoscaling-group-3.name
  }
}