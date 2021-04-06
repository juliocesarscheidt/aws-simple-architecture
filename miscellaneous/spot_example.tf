# resource "aws_spot_fleet_request" "spot_fleet" {
#   iam_fleet_role       = "arn:aws:iam::829560024531:role/AmazonEC2SpotFleetRole"
#   allocation_strategy  = "lowestPrice" # lowestPrice/diversified
#   target_capacity      = 1
#   fleet_type           = "maintain"
#   valid_until          = "2099-01-01T00:00:00Z"
#   spot_price           = "0.04"
#   wait_for_fulfillment = true

#   replace_unhealthy_instances         = true
#   terminate_instances_with_expiration = true
#   excess_capacity_termination_policy  = "Default"

#   dynamic "launch_specification" {
#     for_each = aws_subnet.private_subnet.*

#     content {
#       # availability_zone        = launch_specification.key
#       instance_type            = var.aws_instance_size
#       subnet_id                = launch_specification.value.id
#       ami                      = data.aws_ami.ec2_ami.id
#       iam_instance_profile_arn = "arn:aws:iam::829560024531:instance-profile/AmazonEC2Role"

#       # SSH access to instances will be not enabled
#       # key_name        = var.aws_key_name

#       user_data              = data.template_file.user_data.rendered
#       vpc_security_group_ids = [aws_security_group.instance_sg.id]

#       root_block_device {
#         volume_size           = "20"
#         volume_type           = "gp2"
#         delete_on_termination = true
#       }

#       tags = {
#         Name = "spot-instance"
#       }
#     }
#   }

#   lifecycle {
#     create_before_destroy = true
#     ignore_changes        = [target_capacity, instance_pools_to_use_count]
#   }
# }

# resource "aws_appautoscaling_target" "spot_fleet_target" {
#   min_capacity = 1
#   max_capacity = 3
#   resource_id  = "spot-fleet-request/${aws_spot_fleet_request.spot_fleet.id}"
#   # role_arn           = "arn:aws:iam::829560024531:role/aws-service-role/ec2.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_EC2SpotFleetRequest"
#   scalable_dimension = "ec2:spot-fleet-request:TargetCapacity"
#   service_namespace  = "ec2"
# }

# resource "aws_appautoscaling_policy" "spot_fleet_scaling_policy" {
#   name               = "EC2SpotFleetRequestAverageCPUUtilization:${aws_appautoscaling_target.spot_fleet_target.resource_id}"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.spot_fleet_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.spot_fleet_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.spot_fleet_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "EC2SpotFleetRequestAverageCPUUtilization"
#     }

#     scale_in_cooldown  = 180
#     scale_out_cooldown = 180
#     target_value       = 60
#   }

#   depends_on = [aws_appautoscaling_target.spot_fleet_target]
# }
