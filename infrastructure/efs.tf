//EFS is storing a mountable drive that the various ECS containers can use. This space will hold all the files that modify the base CKAN install.

resource "aws_efs_file_system" "efs" {
}

resource "aws_efs_mount_target" "efs-a" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id      = "${module.vpc.private_subnets.0}"
    security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_mount_target" "efs-b" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id      = "${module.vpc.private_subnets.1}"
    security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_mount_target" "efs-c" {
  file_system_id = "${aws_efs_file_system.efs.id}"
  subnet_id      = "${module.vpc.private_subnets.2}"
  security_groups = ["${aws_security_group.efs.id}"]
}