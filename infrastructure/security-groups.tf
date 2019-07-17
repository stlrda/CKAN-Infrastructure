variable "admin_ip" {}

resource "aws_security_group" "elb" {
  name        = "elb"
  description = "allow from anywhere"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "ecs-to-elb" {
  type = "ingress"
  description     = "allow all from ECS"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  source_security_group_id = "${aws_security_group.ecs.id}"
  security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "allow from ECS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "from ecs"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs.id]
  }

}

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "allow from ELB"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "from ELB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb.id]
  }

}

resource "aws_security_group" "database" {
  name        = "database"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "from ecs"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "administrative" {
  name        = "administrative"
  description = "all traffic from admin ip"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "all from admin ip"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["${var.admin_ip}/32"]
  }
}

resource "aws_security_group" "redis" {
  name        = "redis"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "from ecs"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs.id]
  }
}

resource "aws_security_group" "solr" {
  name        = "solr"
  description = "allow from ecs or elb"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "from ecs"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs.id]
  }

  ingress {
    description     = "from ELB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb.id]
  }
}

resource "aws_security_group" "datapusher" {
  name        = "datapusher"
  description = "allow from ecs, all outbound"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "from ecs"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
