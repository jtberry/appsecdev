provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "appsec-ec2" {
  ami                    = "ami-00448a337adc93c05"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_access.id]
  user_data              = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              python3 -m http.server ${var.server_port}
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-appsec"
  }
}

resource "aws_security_group" "http_access" {
  name        = "terraform-example-instance"
  description = "a SG to allow testing for port 8080"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value       = aws_instance.appsec-ec2.public_ip
  description = "The public IP address of the web server"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}