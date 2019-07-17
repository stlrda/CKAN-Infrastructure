variable "hosted_zone" {}

data "aws_route53_zone" "zone" {
  zone_id = var.hosted_zone
  private_zone = false
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name = aws_route53_record.zone_apex.fqdn
  type = "A"

  alias {
    evaluate_target_health = true
    name                   = "${aws_alb.application-load-balancer.dns_name}"
    zone_id                = "${aws_alb.application-load-balancer.zone_id}"
  }
}

resource "aws_route53_record" "zone_apex" {
  name = ""
  type = "TXT"
  records = ["hello"]
  zone_id = data.aws_route53_zone.zone.zone_id
  ttl = 300
}

resource "aws_route53_record" "route53_record" {
  name    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_route53_record" "rds_cname" {
  name = "db"
  type = "CNAME"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_db_instance.database.endpoint}"]
  ttl = 300
}
