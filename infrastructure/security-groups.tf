resource "aws_security_group" "elb" {
  name        = "elb"
  description = "allow http/s from anywhere"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "efs" {
  name        = "efs"
  description = "allow from ECS"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "all-outbound" {
  name        = "all-outbound"
  description = "allow to anywhere"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "allow from ELB"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "database" {
  name        = "database"
  description = "allow from ckan"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "administrative" {
  name        = "administrative"
  description = "all traffic from admin ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "redis" {
  name        = "redis"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "ckan" {
  name        = "ckan"
  description = "allow from elb/datapusher"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "datapusher" {
  name        = "datapusher"
  description = "allow from elb/ckan"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "solr" {
  name        = "solr"
  description = "allow from ecs"
  vpc_id      = module.vpc.vpc_id
}