resource "aws_service_discovery_private_dns_namespace" "ckan-infrastructure" {
  name        = "ckan-infrastructure.local"
  description = "ckan local service discovery namespace"
  vpc         = "${module.vpc.vpc_id}"
}

resource "aws_service_discovery_service" "solr" {
  name = "solr"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.ckan-infrastructure.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "datapusher" {
  name = "datapusher"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.ckan-infrastructure.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
