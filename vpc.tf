# Variables
variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

# VPC
resource "aws_vpc" "cert_files" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "cert_files"
  }
}
