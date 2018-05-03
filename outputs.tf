output "endpoint" {
  value = "${aws_alb.main.dns_name}"
}

output "alb_zone_id" {
  value = "${aws_alb.main.zone_id}"
}
