//The auto-scaling group determines how many containers are running behind the load balancer

resource "aws_placement_group" "ecs-spread-placement-group" {
  name     = "spread-placement-group"
  strategy = "spread"
}

//@michael, please explain need for min_size=3 here
resource "aws_autoscaling_group" "ecs" {
  name                      = local.name
  max_size                  = 6
  min_size                  = 6
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 6
  force_delete              = true
  placement_group           = "${aws_placement_group.ecs-spread-placement-group.id}"
  vpc_zone_identifier       = module.vpc.public_subnets

  launch_template {
    id      = "${aws_launch_template.ecs.id}"
    version = "$Latest"
  }

  timeouts {
    delete = "15m"
  }

  //  delete the ASG before the opsworks stack on destroy
  depends_on = [
    "aws_opsworks_stack.opsworks",
    "aws_sns_topic_subscription.deregister-ec2-from-opsworks",
    "aws_lambda_function.deregister-ec2-from-opsworks"
  ]

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = ["desired_capacity"]
  }

}

resource "aws_autoscaling_notification" "autoscaling-notification" {
  group_names = [
    "${aws_autoscaling_group.ecs.name}"
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_TERMINATE"
  ]

  topic_arn = "${aws_sns_topic.autoscale-notification-topic.arn}"
}
