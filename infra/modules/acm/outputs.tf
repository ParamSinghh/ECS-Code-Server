# Output the certificate ARN
# The ALB needs this to attach the certificate to the HTTPS listener
output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.this.certificate_arn
}