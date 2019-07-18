variable "admin_ip" {}

//---- elb

resource "aws_security_group" "elb" {
  name        = "elb"
  description = "allow http/s from anywhere"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all-http-to-elb" {
  description       = "all-http-to-elb"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "all-https-to-elb" {
  description       = "all-https-to-elb"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.elb.id}"
}

//---- efs

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "allow from ECS"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ecs-to-efs" {
  description = "from ecs"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.efs.id}"
  source_security_group_id = "${aws_security_group.ecs.id}"
  to_port = 0
  type = "ingress"
}

//---- all-outbound

resource "aws_security_group" "all-outbound" {
  name        = "all-outbound"
  description = "allow to anywhere"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
}

//---- ecs

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "allow from ELB"
  vpc_id      = module.vpc.vpc_id
}

//---- database

resource "aws_security_group" "database" {
  name        = "database"
  description = "allow from ckan"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ckan-to-database" {
  description = "ckan-to-database"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.database.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.ckan.id}"
}

//---- administrative

resource "aws_security_group" "administrative" {
  name        = "administrative"
  description = "all traffic from admin ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all-from-admin-ip" {
  description = "all-from-admin-ip"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.administrative.id}"
  to_port = 0
  type = "ingress"
  cidr_blocks = ["${var.admin_ip}/32"]
}

//---- redis

resource "aws_security_group" "redis" {
  name        = "redis"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ckan-to-redis" {
  description = "ckan-to-redis"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.redis.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.ckan.id}"
}

//---- ckan

resource "aws_security_group" "ckan" {
  name        = "ckan"
  description = "allow from elb/datapusher"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "datapusher-to-ckan" {
  description = "datapusher-to-ckan"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ckan.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.datapusher.id}"
}

resource "aws_security_group_rule" "elb-to-ckan" {
  description = "elb-to-ckan"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ckan.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.elb.id}"
}

//---- datapusher

resource "aws_security_group" "datapusher" {
  name        = "datapusher"
  description = "allow from elb/ckan"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ckan-to-datapusher" {
  description = "ckan-to-datapusher"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.datapusher.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.ckan.id}"
}

resource "aws_security_group_rule" "elb-to-datapusher" {
  description = "elb-to-datapusher"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.datapusher.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.elb.id}"
}

//---- solr

resource "aws_security_group" "solr" {
  name        = "solr"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ckan-to-solr" {
  description = "ckan-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ckan.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.solr.id}"
}

resource "aws_security_group_rule" "elb-to-solr" {
  description = "elb-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.elb.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.solr.id}"
}

resource "aws_security_group_rule" "ecs-to-solr" {
  description = "ecs-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ecs.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.solr.id}"
}