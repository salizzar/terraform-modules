resource "aws_key_pair" "app" {
  key_name   = "${var.aws_key_pair["key_name"]}"
  public_key = "${var.aws_key_pair["public_key"]}"
}

resource "aws_launch_configuration" "lc" {
  name_prefix   = "${var.aws_launch_configuration["name_prefix"]}"
  image_id      = "${var.aws_launch_configuration["image_id"]}"
  instance_type = "${var.aws_launch_configuration["instance_type"]}"

  security_groups = ["${split(", ", var.aws_launch_configuration["security_groups"])}"]
  user_data       = "${var.aws_launch_configuration["user_data"]}"
  key_name        = "${aws_key_pair.app.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name             = "${var.aws_autoscaling_group["name"]}-${aws_launch_configuration.lc.name}"
  min_size         = "${var.aws_autoscaling_group["min_size"]}"
  max_size         = "${var.aws_autoscaling_group["max_size"]}"
  desired_capacity = "${var.aws_autoscaling_group["desired_capacity"]}"

  vpc_zone_identifier = ["${split(", ", var.aws_autoscaling_group["vpc_zone_identifier"])}"]
  target_group_arns   = ["${data.aws_alb_target_group.tg.arn}"]

  launch_configuration = "${aws_launch_configuration.lc.name}"
  force_delete         = true

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.aws_autoscaling_group["tag_name"]}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Release"
    value               = "${var.aws_autoscaling_group["tag_release"]}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${terraform.workspace}"
    propagate_at_launch = true
  }

  tag {
    key                 = "CreatedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale-up" {
  name                   = "${var.aws_autoscaling_policy_scale-up["name"]}"
  scaling_adjustment     = "${var.aws_autoscaling_policy_scale-up["scaling_adjustment"]}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.aws_autoscaling_policy_scale-up["cooldown"]}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_policy" "scale-down" {
  name                   = "${var.aws_autoscaling_policy_scale-down["name"]}"
  scaling_adjustment     = "${var.aws_autoscaling_policy_scale-down["scaling_adjustment"]}"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.aws_autoscaling_policy_scale-down["cooldown"]}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-up" {
  count = "${var.aws_cloudwatch_metric_alarm_cpu-up["count"]}"

  alarm_name          = "${var.aws_cloudwatch_metric_alarm_cpu-up["alarm_name"]}"
  alarm_description   = "${var.aws_cloudwatch_metric_alarm_cpu-up["alarm_description"]}"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  evaluation_periods  = "${var.aws_cloudwatch_metric_alarm_cpu-up["evaluation_periods"]}"
  period              = "${var.aws_cloudwatch_metric_alarm_cpu-up["period"]}"
  threshold           = "${var.aws_cloudwatch_metric_alarm_cpu-up["threshold"]}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = [
    "${aws_autoscaling_policy.scale-up.arn}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu-down" {
  count = "${var.aws_cloudwatch_metric_alarm_cpu-down["count"]}"

  alarm_name          = "${var.aws_cloudwatch_metric_alarm_cpu-down["alarm_name"]}"
  alarm_description   = "${var.aws_cloudwatch_metric_alarm_cpu-down["alarm_description"]}"
  metric_name         = "CPUUtilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  evaluation_periods  = "${var.aws_cloudwatch_metric_alarm_cpu-down["evaluation_periods"]}"
  period              = "${var.aws_cloudwatch_metric_alarm_cpu-down["period"]}"
  threshold           = "${var.aws_cloudwatch_metric_alarm_cpu-down["threshold"]}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = [
    "${aws_autoscaling_policy.scale-down.arn}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "ram-up" {
  count = "${var.aws_cloudwatch_metric_alarm_ram-up["count"]}"

  alarm_name          = "${var.aws_cloudwatch_metric_alarm_ram-up["alarm_name"]}"
  alarm_description   = "${var.aws_cloudwatch_metric_alarm_ram-up["alarm_description"]}"
  metric_name         = "MemoryUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "System/Linux"
  statistic           = "Average"
  evaluation_periods  = "${var.aws_cloudwatch_metric_alarm_ram-up["evaluation_periods"]}"
  period              = "${var.aws_cloudwatch_metric_alarm_ram-up["period"]}"
  threshold           = "${var.aws_cloudwatch_metric_alarm_ram-up["threshold"]}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = [
    "${aws_autoscaling_policy.scale-up.arn}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "ram-down" {
  count = "${var.aws_cloudwatch_metric_alarm_ram-down["count"]}"

  alarm_name          = "${var.aws_cloudwatch_metric_alarm_ram-down["alarm_name"]}"
  alarm_description   = "${var.aws_cloudwatch_metric_alarm_ram-down["alarm_description"]}"
  metric_name         = "MemoryUtilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "System/Linux"
  statistic           = "Average"
  evaluation_periods  = "${var.aws_cloudwatch_metric_alarm_ram-down["evaluation_periods"]}"
  period              = "${var.aws_cloudwatch_metric_alarm_ram-down["period"]}"
  threshold           = "${var.aws_cloudwatch_metric_alarm_ram-down["threshold"]}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_actions = [
    "${aws_autoscaling_policy.scale-down.arn}",
  ]
}
