/*
# ecs

A terraform module to create ecs resources
*/

locals {
  name        = "ecs"
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

#----- ECS --------
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name   = local.name
}


#----- ECS Services--------

resource "aws_ecs_service" "ckan" {
  name                               = "ckan"
  task_definition                    = "${aws_ecs_task_definition.ckan.id}"
  cluster                            = "${module.ecs.this_ecs_cluster_name}"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ckan-http.id}"
    container_name   = "ckan"
    container_port   = "5000"
  }

  health_check_grace_period_seconds = 600

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      "${aws_security_group.ckan.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.ckan.arn}"
  }

  depends_on = [
    "aws_alb_listener.ckan-http",
    "aws_alb_listener.ckan-https",
    "aws_alb_listener.solr-http"
  ]

  # Optional: Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = ["desired_count"]
  }

}

resource "aws_ecs_service" "datapusher" {
  name            = "datapusher"
  task_definition = "${aws_ecs_task_definition.datapusher.id}"
  cluster         = "${module.ecs.this_ecs_cluster_name}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_alb_target_group.datapusher-http.id}"
    container_name   = "datapusher"
    container_port   = "8800"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.datapusher.arn}"
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      "${aws_security_group.datapusher.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }

}

resource "aws_ecs_service" "solr" {
  name            = "solr"
  task_definition = "${aws_ecs_task_definition.solr.id}"
  cluster         = "${module.ecs.this_ecs_cluster_name}"
  desired_count   = 1

  health_check_grace_period_seconds = 30

  load_balancer {
    target_group_arn = "${aws_alb_target_group.solr-http.id}"
    container_name   = "solr"
    container_port   = "8983"
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.solr.arn}"
  }

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      "${aws_security_group.solr.id}",
      "${aws_security_group.all-outbound.id}"
    ]
  }

  depends_on = [
    "aws_alb_listener.solr-http"
  ]

}

#----- ECS Task Definitions--------


resource "aws_ecs_task_definition" "ckan" {
  family                = "ckan"
  container_definitions = data.template_file.container-definition-ckan.rendered

  volume {
    name      = "efs-ckan-storage"
    host_path = "/mnt/efs/ckan/storage"
  }

  network_mode = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.ckan]

}

data "template_file" "container-definition-ckan" {
  template = file("${path.module}/templates/task-definitions/ckan.json")

  vars = {
    CKAN_SITE_URL               = aws_route53_record.zone_apex.fqdn
    DATABASE_URL                = aws_db_instance.database.address
    CKAN_MAX_UPLOAD_SIZE_MB     = 50
    POSTGRES_USER               = aws_db_instance.database.username
    POSTGRES_PASSWORD           = aws_db_instance.database.password
    DATASTORE_READONLY_USER     = "datastore_ro"
    DATASTORE_READONLY_PASSWORD = "${var.datastore_readonly_password}"
    ELASTICACHE_ENDPOINT        = aws_elasticache_cluster.redis.cache_nodes.0.address
    SOLR_ENDPOINT               = "${aws_service_discovery_service.solr.name}.${aws_service_discovery_private_dns_namespace.ckan-infrastructure.name}"
    DATAPUSHER_ENDPOINT         = "${aws_service_discovery_service.datapusher.name}.${aws_service_discovery_private_dns_namespace.ckan-infrastructure.name}"
    AWSLOGS_GROUP               = "${aws_cloudwatch_log_group.ckan.name}"
    AWSLOGS_REGION              = "${var.region}"
    AWSLOGS_STREAM_PREFIX       = "ecs"
    CKAN_SYSADMIN_NAME          = "${var.ckan_admin}"
    CKAN_SYSADMIN_PASSWORD      = "${var.ckan_admin_password}"
  }

  depends_on = [aws_cloudwatch_log_group.ckan]

}

resource "aws_ecs_task_definition" "datapusher" {
  family                = "datapusher"
  container_definitions = data.template_file.container-definition-datapusher.rendered

  network_mode = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.datapusher]

}

data "template_file" "container-definition-datapusher" {
  template = file("${path.module}/templates/task-definitions/datapusher.json")

  vars = {
    AWSLOGS_GROUP         = aws_cloudwatch_log_group.datapusher.name
    AWSLOGS_REGION        = var.region
    AWSLOGS_STREAM_PREFIX       = "ecs"
  }

  depends_on = [aws_cloudwatch_log_group.datapusher]

}


resource "aws_ecs_task_definition" "solr" {
  family                = "solr"
  container_definitions = data.template_file.container-definition-solr.rendered

  volume {
    name      = "efs-solr"
    host_path = "/mnt/efs/solr"
  }

  network_mode = "awsvpc"

  depends_on = [aws_cloudwatch_log_group.solr]

}

data "template_file" "container-definition-solr" {
  template = file("${path.module}/templates/task-definitions/solr.json")

  vars = {
    AWSLOGS_GROUP         = aws_cloudwatch_log_group.solr.name
    AWSLOGS_REGION        = var.region
    AWSLOGS_STREAM_PREFIX       = "ecs"
  }

  depends_on = [aws_cloudwatch_log_group.solr]

}