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