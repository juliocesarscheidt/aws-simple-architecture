######## ON DEMAND ########
resource "aws_launch_template" "instance_launch_template" {
  name = "instance_launch_template"

  image_id               = data.aws_ami.ec2_ami.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  iam_instance_profile {
    name = var.aws_instance_role
  }

  user_data = filebase64("${path.module}/templates/user_data.sh")

  instance_initiated_shutdown_behavior = "terminate"

  # SSH access to instances will be not enabled
  # key_name        = var.aws_key_name
  instance_type = var.aws_instance_size
  ebs_optimized = false

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = "15"
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  # tags to be added on instance
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "on-demand-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "instance_asg" {
  name = "instance_asg"

  desired_capacity = lookup(var.aws_instance_asg_options, "desired_capacity", 1)
  min_size         = lookup(var.aws_instance_asg_options, "min_size", 1)
  max_size         = lookup(var.aws_instance_asg_options, "max_size", 2)

  capacity_rebalance = true

  # all instances will be placed into private subnets
  vpc_zone_identifier = aws_subnet.private_subnet.*.id

  health_check_type         = "EC2"
  health_check_grace_period = 300

  force_delete = true

  launch_template {
    id      = aws_launch_template.instance_launch_template.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_subnet.private_subnet]
}

resource "aws_autoscaling_attachment" "instance_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.instance_asg.id
  # it makes these instances be included in this target group
  alb_target_group_arn = aws_alb_target_group.application-lb-tg.arn

  depends_on = [aws_autoscaling_group.instance_asg, aws_alb_target_group.application-lb-tg]
}

####### SPOT ########
resource "aws_launch_template" "spot_launch_template" {
  name = "spot_launch_template"

  image_id               = data.aws_ami.ec2_ami.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  iam_instance_profile {
    name = var.aws_instance_role
  }

  user_data = filebase64("${path.module}/templates/user_data.sh")

  instance_initiated_shutdown_behavior = "terminate"

  # SSH access to instances will be not enabled
  # key_name        = var.aws_key_name
  instance_type = var.aws_instance_size
  ebs_optimized = false

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = "15"
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      max_price                      = "0.05"
      # spot_instance_type = "persistent" # one-time/persistent default one-time
      # valid_until = "2099-01-01T00:00:00Z"
    }
  }

  # tags to be added on instance
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "spot-instance"
    }
  }

  # tags to be added on spot request
  tag_specifications {
    resource_type = "spot-instances-request"

    tags = {
      Name = "spot-instances-request"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "spot_asg" {
  name = "spot_asg"

  desired_capacity = lookup(var.aws_spot_asg_options, "desired_capacity", 2)
  min_size         = lookup(var.aws_spot_asg_options, "min_size", 2)
  max_size         = lookup(var.aws_spot_asg_options, "max_size", 4)

  capacity_rebalance = true

  # all instances will be placed into private subnets
  vpc_zone_identifier = aws_subnet.private_subnet.*.id

  health_check_type         = "EC2"
  health_check_grace_period = 300

  force_delete = true

  launch_template {
    id      = aws_launch_template.spot_launch_template.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_subnet.private_subnet]
}

resource "aws_autoscaling_attachment" "spot_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.spot_asg.id
  # it makes these instances be included in this target group
  alb_target_group_arn = aws_alb_target_group.application-lb-tg.arn

  depends_on = [aws_autoscaling_group.spot_asg, aws_alb_target_group.application-lb-tg]
}
