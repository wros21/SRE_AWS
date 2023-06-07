# Variables
variable "vpc_id" {
  description = "ID de la VPC"
}

# Security Groups
resource "aws_security_group" "ec2_security_group" {
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

}

resource "aws_security_group" "elb_security_group" {
  vpc_id      = var.vpc_id

  # Regla para permitir tráfico HTTP (puerto 80) desde cualquier origen
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla para permitir tráfico HTTPS (puerto 443) desde cualquier origen
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla para permitir tráfico desde el grupo de seguridad de EC2
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ec2_security_group.id]
  }
}

}

resource "aws_security_group" "asg_security_group" {
  vpc_id      = var.vpc_id

  # Regla para permitir tráfico desde el grupo de seguridad de ELB
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb_security_group.id]
  }

  # Regla para permitir tráfico desde el grupo de seguridad de EC2
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ec2_security_group.id]
  }

  # Regla para permitir tráfico desde el grupo de seguridad de K8s y Docker
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.k8s_docker_security_group.id]
  }
}


resource "aws_security_group" "dynamodb_security_group" {
  vpc_id      = var.vpc_id

  # Regla para permitir acceso desde el grupo de seguridad de EC2
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ec2_security_group.id]
  }

  # Regla para permitir acceso desde el grupo de seguridad de ELB
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb_security_group.id]
  }
}


resource "aws_s3_bucket" "doc_files_bucket" {
  bucket = "Doc_files"
}

resource "aws_s3_bucket_policy" "doc_files_bucket_policy" {
  bucket = aws_s3_bucket.doc_files_bucket.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "RestrictIPAccess",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.doc_files_bucket.id}/*"
        ],
        "Condition": {
          "IpAddress": {
            "aws:SourceIp": [
              "10.10.16.0/19",
              "10.10.32.0/19"
            ]
          }
        }
      }
    ]
  })
}


resource "aws_security_group" "k8s_docker_security_group" {
  vpc_id      = var.vpc_id

  # Regla para permitir el tráfico hacia los pods de API en la AZ1
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ec2_security_group.id]
    source_security_group_id = aws_security_group.ec2_security_group.id
  }

  # Regla para permitir el tráfico hacia los pods de API en la AZ2
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ec2_security_group.id]
    source_security_group_id = aws_security_group.ec2_security_group.id
  }
}

