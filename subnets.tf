# Variables
variable "vpc_id" {
  description = "ID de la VPC"
}

variable "subnet_cidr_public_1" {
  default = "10.10.1.0/20"
}

variable "subnet_cidr_public_2" {
  default = "10.10.2.0/20"
}

variable "subnet_cidr_private_1" {
  default = "10.10.16.0/19"
}

variable "subnet_cidr_private_2" {
  default = "10.10.32.0/19"
}

# Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_public_1
  availability_zone       = "us-west-1a" 
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_public_2
  availability_zone       = "us-west-1b" 
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_private_1
  availability_zone       = "us-west-1a" 
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr_private_2
  availability_zone       = "us-west-1b" 
}
