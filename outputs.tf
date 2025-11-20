# OUTPUTS - Expose Infrastructure Details After Deployment


output "vpc_id" {
  description = "ID of the VPC"
  value = aws_vpc.dev-vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value= aws_subnet.dev-subnet-public-1.id
}

output "subnet_cidr" {
  description = "CIDR block of the public subnet"
  value= aws_subnet.dev-subnet-public-1.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value = aws_internet_gateway.dev-igw.id
}

output "security_group_id" {
  description = "ID of the security group"
  value  = aws_security_group.ssh-allowed.id
}

output "security_group_name" {
  description = "Name of the security group"
  value = aws_security_group.ssh-allowed.name
}

output "key_pair_name" {
  description = "Name of the SSH key pair"
  value = aws_key_pair.oregon-region-key-pair.key_name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value  = aws_launch_template.dev-launch-config.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value = aws_launch_template.dev-launch-config.latest_version_number
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value = aws_autoscaling_group.dev-autoscaling-group-3.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value = aws_autoscaling_group.dev-autoscaling-group-3.arn
}

output "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.dev-autoscaling-group-3.min_size
}

output "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.dev-autoscaling-group-3.max_size
}

output "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.dev-autoscaling-group-3.desired_capacity
}

output "asg_vpc_zone_identifier" {
  description = "VPC zones where ASG launches instances"
  value = aws_autoscaling_group.dev-autoscaling-group-3.vpc_zone_identifier
}

output "scale_up_policy_arn" {
  description = "ARN of the scale-up autoscaling policy"
  value = aws_autoscaling_policy.scale-up.arn
}

output "scale_down_policy_arn" {
  description = "ARN of the scale-down autoscaling policy"
  value = aws_autoscaling_policy.scale-down.arn
}

output "cloudwatch_cpu_high_alarm_name" {
  description = "Name of the CloudWatch alarm for high CPU"
  value= aws_cloudwatch_metric_alarm.cpu-high.alarm_name
}

output "cloudwatch_cpu_low_alarm_name" {
  description = "Name of the CloudWatch alarm for low CPU"
  value= aws_cloudwatch_metric_alarm.cpu-low.alarm_name
}

output "deployment_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    region              = var.AWS_REGION
    vpc_cidr            = aws_vpc.dev-vpc.cidr_block
    subnet_cidr         = aws_subnet.dev-subnet-public-1.cidr_block
    asg_name            = aws_autoscaling_group.dev-autoscaling-group-3.name
    min_instances       = aws_autoscaling_group.dev-autoscaling-group-3.min_size
    max_instances       = aws_autoscaling_group.dev-autoscaling-group-3.max_size
    desired_instances   = aws_autoscaling_group.dev-autoscaling-group-3.desired_capacity
    instance_type       = var.INSTANCE_TYPE
    health_check_type   = aws_autoscaling_group.dev-autoscaling-group-3.health_check_type
    health_check_period = "${aws_autoscaling_group.dev-autoscaling-group-3.health_check_grace_period} seconds"
  }
}