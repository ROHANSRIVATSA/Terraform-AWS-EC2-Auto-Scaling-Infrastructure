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
    key = "Name"
    value = "dev-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key = "ASGName"
    value = "dev-asg-3"
    propagate_at_launch = true
  }

  tag {
    key = "Environment"
    value = "Development"
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