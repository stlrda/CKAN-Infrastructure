resource "aws_opsworks_stack" "opsworks" {
  name                          = "opsworks"
  region                        = var.region
  service_role_arn              = "${aws_iam_role.service-role-for-opsworks.arn}"
  default_instance_profile_arn  = "${aws_iam_instance_profile.instance-profile-for-ecs.arn}"
  vpc_id = "${module.vpc.vpc_id}"
  default_subnet_id = "${module.vpc.public_subnets.0}"
  //  using opsworks default security groups will cause "terraform destroy" to fail because terraform does not know the security groups belonging to the VPC exist
  use_opsworks_security_groups  = false
  configuration_manager_name    = "Chef"
  configuration_manager_version = "12"
  default_os                    = "Amazon Linux 2"
  default_root_device_type      = "ebs"
  hostname_theme                = "Layer_Dependent"
  manage_berkshelf              = false
  use_custom_cookbooks          = false

  depends_on = [
//    workaround for https://github.com/terraform-providers/terraform-provider-aws/issues/14
    "aws_iam_role.service-role-for-opsworks",
    "aws_lambda_function.deregister-ec2-from-opsworks",
    "aws_sns_topic.autoscale-notification-topic",
    "aws_iam_instance_profile.instance-profile-for-ecs",
    "aws_iam_policy.opsworks-service-role-policy",
    "aws_iam_role_policy_attachment.opsworks-service-role-policy-attachment"]
}
