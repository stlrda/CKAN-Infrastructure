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
  name            = "ckan"
  task_definition = "${aws_ecs_task_definition.ckan.id}"
  cluster         = "${module.ecs.this_ecs_cluster_name}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ckan-http.id}"
    container_name   = "ckan"
    container_port   = "5000"
  }

  health_check_grace_period_seconds = 600

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

  service_registries {
    registry_arn = "${aws_service_discovery_service.datapusher.arn}"
  }
}

resource "aws_ecs_service" "solr" {
  name            = "solr"
  task_definition = "${aws_ecs_task_definition.solr.id}"
  cluster         = "${module.ecs.this_ecs_cluster_name}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${aws_alb_target_group.solr-http.id}"
    container_name   = "solr"
    container_port   = "8983"
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
    name      = "efs-ckan-config"
    host_path = "/mnt/efs/ckan/config"
  }
  volume {
    name      = "efs-ckan-home"
    host_path = "/mnt/efs/ckan/home"
  }
  volume {
    name      = "efs-ckan-storage"
    host_path = "/mnt/efs/ckan/storage"
  }

}

data "template_file" "container-definition-ckan" {
  template = file("${path.module}/templates/task-definitions/ckan.json")

  vars = {
    CKAN_SITE_URL               = aws_route53_record.zone_apex.fqdn
    DATABASE_URL                = aws_db_instance.database.address
    CKAN_MAX_UPLOAD_SIZE_MB     = 50
    POSTGRES_USER               = aws_db_instance.database.username
    POSTGRES_PASSWORD           = aws_db_instance.database.password
    DATASTORE_READONLY_USER     = aws_db_instance.database.username
    DATASTORE_READONLY_PASSWORD = aws_db_instance.database.password
    ELASTICACHE_ENDPOINT        = aws_elasticache_cluster.redis.cache_nodes.0.address
    SOLR_ENDPOINT               = "${aws_alb.application-load-balancer.dns_name}"
    DATAPUSHER_ENDPOINT         = "${aws_service_discovery_service.datapusher.name}.${aws_service_discovery_private_dns_namespace.ckan-infrastructure.name}"

  }

  depends_on = [aws_cloudwatch_log_group.ckan]

}

resource "aws_ecs_task_definition" "datapusher" {
  family                = "datapusher"
  container_definitions = "${file("templates/task-definitions/datapusher.json")}"

  volume {
    name      = "efs-datapusher"
    host_path = "/mnt/efs/datapusher"
  }

  depends_on = [aws_cloudwatch_log_group.datapusher]

}

resource "aws_ecs_task_definition" "solr" {
  family                = "solr"
  container_definitions = "${file("templates/task-definitions/solr.json")}"

  volume {
    name      = "efs-solr"
    host_path = "/mnt/efs/solr"
  }

  depends_on = [aws_cloudwatch_log_group.solr]

}