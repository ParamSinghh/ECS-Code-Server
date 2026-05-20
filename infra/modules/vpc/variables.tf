# The project name used for naming all resources
variable "project_name" {
  description = "Project name"
  type        = string
}

# The IP range for the whole VPC
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  # Default is 10.0.0.0/16 which gives us 65,000 IPs
  default     = "10.0.0.0/16"
}

# The IP ranges for each public subnet
variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  # Each subnet gets a smaller range inside the VPC
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# Which availability zones to create subnets in
variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  # Using all 3 London availability zones for high availability
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}