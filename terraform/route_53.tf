data "aws_route53_zone" "root_zone" {
  name = "${var.root_domain}."

  depends_on = [aws_lb.application-lb]
}

# create a record as alias pointing to load balancer
resource "aws_route53_record" "alb_record" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.root_zone.zone_id
  name            = "cluster.${var.root_domain}"
  type            = "A"

  alias {
    name                   = aws_lb.application-lb.dns_name
    zone_id                = aws_lb.application-lb.zone_id
    evaluate_target_health = false
  }

  depends_on = [data.aws_route53_zone.root_zone]
}

resource "aws_route53_record" "alb_record_www" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.root_zone.zone_id
  name            = "www.cluster.${var.root_domain}"
  type            = "CNAME"
  ttl             = 60

  records = ["cluster.${var.root_domain}"]

  depends_on = [data.aws_route53_zone.root_zone]
}
