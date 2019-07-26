//WARNING: repeated apply/destroys can easily hit AWS's annual certificate creation limit.
//A support ticket can be opened to increase that limit.

resource "aws_acm_certificate" "certificate" {
  domain_name       = aws_route53_record.zone_apex.fqdn
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.route53_record.fqdn}"]
  lifecycle {
    create_before_destroy = true
  }
}
