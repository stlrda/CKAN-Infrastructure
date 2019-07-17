data "template_file" "user_data" {
  template = file("${path.module}/templates/userdata.sh")

  vars = {
    cluster_name      = local.name
    efs_filesystem_id = aws_efs_file_system.efs.id
    efs_directory     = "/mnt/efs"
    region            = var.region
    stack_id          = aws_opsworks_stack.opsworks.id
  }
}

# Use the most recent AWS Amazon Linux 2 ECS optimized ami 
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = [
  "amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name = "owner-alias"
    values = [
    "amazon"]
  }
}

resource "aws_launch_template" "ecs" {
  name                                 = "ecs"
  ebs_optimized                        = true
  image_id                             = data.aws_ami.amazon_linux_ecs.id
  user_data                            = "${base64encode(data.template_file.user_data.rendered)}"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.small"

  network_interfaces {
    security_groups = [
      "${aws_security_group.ecs.id}",
      "${aws_security_group.administrative.id}"
    ]
    delete_on_termination       = true
    associate_public_ip_address = true
  }

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.instance-profile-for-ecs.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name          = "ECS"
      "ECS Cluster" = local.name
      opsworks_stack_id = "${aws_opsworks_stack.opsworks.id}"
    }
  }
}

