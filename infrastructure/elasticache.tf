//@michael, what is elasticache being use for/what is it storing?

resource "aws_elasticache_parameter_group" "redis" {
  name = "redis"
  family = "redis5.0"
  description = "redis 5.0 parameter group"
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  engine_version       = "5.0.4"
  subnet_group_name = module.vpc.elasticache_subnet_group_name
  security_group_ids = ["${aws_security_group.redis.id}"]
}
