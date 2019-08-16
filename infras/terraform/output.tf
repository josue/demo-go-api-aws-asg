output "api_endpoint" {
  description = "ELB - API Endpoint"
  value       = "http://${aws_elb.api_elb.dns_name}"
}
