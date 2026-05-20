# Request a public SSL/TLS certificate from AWS
resource "aws_acm_certificate" "this" {
  # The domain name to issue the certificate for
  domain_name       = var.domain_name
  # Use DNS validation - AWS adds a record to Route 53 to prove you own the domain
  validation_method = "DNS"

  tags = {
    Name = var.domain_name
  }

  # If you need to replace the certificate, create the new one before destroying the old one
  lifecycle {
    create_before_destroy = true
  }
}

# Create the DNS validation record in Route 53
# This proves to AWS that you own the domain
resource "aws_route53_record" "cert_validation" {
  # Loop through each domain validation option
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  # The hosted zone to add the validation record to
  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  # Short TTL so it validates quickly
  ttl     = 60
}

# Wait for the certificate to be fully validated and issued
resource "aws_acm_certificate_validation" "this" {
  # The certificate to validate
  certificate_arn         = aws_acm_certificate.this.arn
  # The DNS records that prove we own the domain
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}