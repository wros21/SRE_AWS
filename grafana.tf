provider "aws" {
  region = "us-west-2"  
}

# Crear VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "cert_files"
  }
}

# Crear subredes en la VPC (zona 1 y zona 2)
resource "aws_subnet" "subnet_zone1" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.10.16.0/19"
  availability_zone = "us-west-2a"  
  tags = {
    Name = "subnet_zone1"
  }
}

resource "aws_subnet" "subnet_zone2" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.10.48.0/19"
  availability_zone = "us-west-2b"  
  tags = {
    Name = "subnet_zone2"
  }
}

# Crear instancias de Prometheus y Grafana
resource "aws_instance" "prometheus_instance" {
  ami           = "ami-899899"  
  instance_type = "t2.micro"  
  subnet_id     = aws_subnet.subnet_zone1.id
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id]
}

resource "aws_instance" "grafana_instance" {
  ami           = "ami-899899"  
  instance_type = "t2.micro" 
  subnet_id     = aws_subnet.subnet_zone2.id
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]
}

# Configurar grupos de seguridad
resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus_sg"
  description = "Security group for Prometheus"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

resource "aws_security_group" "grafana_sg" {
  name        = "grafana_sg"
  description = "Security group for Grafana"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

# Recopilar datos de los buckets S3
data "aws_s3_bucket_objects" "bucket1_objects" {
  bucket = "logs"  
}

data "aws_s3_bucket_objects" "bucket2_objects" {
  bucket = "logs" 
}

# Configurar destino de almacenamiento en Prometheus
resource "grafana_prometheus_datasource" "prometheus_ds" {
  name            = "Prometheus"
  type            = "prometheus"
  url             = 10.10.16.2 + ":9090"  
  access          = "proxy"
  is_default      = true
  with_credentials = false
}

resource "grafana_dashboard" "example_dashboard" {
  config_json = <<EOF
{
  "editable": true,
  "rows": [
    {
      "title": "Bucket 1 Metrics",
      "panels": [
        {
          "title": "Panel 1",
          "type": "graph",
          "datasource": "${grafana_prometheus_datasource.prometheus_ds.id}",
          "targets": [
            {
              "expr": "metric_name{bucket=\"bucket1-name\"}"
            }
          ],
          "legend": {
            "show": true
          }
        }
      ]
    },
    {
      "title": "Bucket 2 Metrics",
      "panels": [
        {
          "title": "Panel 2",
          "type": "graph",
          "datasource": "${grafana_prometheus_datasource.prometheus_ds.id}",
          "targets": [
            {
              "expr": "metric_name{bucket=\"bucket2-name\"}"
            }
          ],
          "legend": {
            "show": true
          }
        }
      ]
    }
  ]
}
EOF

  depends_on = [grafana_prometheus_datasource.prometheus_ds]
}
