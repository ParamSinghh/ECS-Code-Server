# The domain name to create the certificate for
# e.g tm.paramsingh.co.uk
variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

# The Route 53 hosted zone ID
# ACM needs this to add the DNS validation record
variable "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}