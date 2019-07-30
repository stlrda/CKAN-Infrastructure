//---- elb

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

resource "aws_security_group_rule" "all-outbound" {
  description = "to anywhere"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.all-outbound.id}"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
}

//---- ecs

resource "aws_security_group_rule" "ecs-to-ecs-ingress" {
  description = "ecs-to-ecs"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ecs.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.ecs.id}"
}

resource "aws_security_group_rule" "ecs-to-ecs-egress" {
  description = "ecs-to-ecs"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ecs.id}"
  to_port = 0
  type = "egress"
  source_security_group_id = "${aws_security_group.ecs.id}"
}

//---- database

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

resource "aws_security_group_rule" "all-from-admin-ip" {
  description = "all-from-admin-ip"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.administrative.id}"
  to_port = 0
  type = "ingress"
  cidr_blocks = var.admin-cidr-blocks
}

//---- redis

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

resource "aws_security_group_rule" "ckan-to-ckan-ingress" {
  description = "ckan-to-ckan"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ckan.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.ckan.id}"
}

resource "aws_security_group_rule" "ckan-to-ckan-egress" {
  description = "ckan-to-ckan"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ckan.id}"
  to_port = 0
  type = "egress"
  source_security_group_id = "${aws_security_group.ckan.id}"
}

//---- datapusher

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

resource "aws_security_group_rule" "ckan-to-solr" {
  description = "ckan-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.solr.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.ckan.id}"
}

resource "aws_security_group_rule" "elb-to-solr" {
  description = "elb-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.solr.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "ecs-to-solr" {
  description = "ecs-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.solr.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.ecs.id}"
}

resource "aws_security_group_rule" "solr-to-solr-ingress" {
  description = "solr-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.solr.id}"
  to_port = 0
  type = "ingress"
  source_security_group_id = "${aws_security_group.solr.id}"
}

resource "aws_security_group_rule" "solr-to-solr-egress" {
  description = "solr-to-solr"
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.solr.id}"
  to_port = 0
  type = "egress"
  source_security_group_id = "${aws_security_group.solr.id}"
}