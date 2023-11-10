provider "aws" {
  region = "us-west-2"
}

resource "aws_launch_configuration" "appsec-ec2" {
  image_id        = "ami-00448a337adc93c05"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.http_access.id]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              python3 -m http.server ${var.server_port}
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "scaling_ec2" {
  launch_configuration = aws_launch_configuration.appsec-ec2.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terr-web-app-ASG"
    propagate_at_launch = true
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

#output "public_ip" {
##  value       = aws_instance.appsec-ec2.public_ip
#  description = "The public IP address of the web server"
#}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "alb_terra_appsec" {
  name               = "alb-terra-appsec"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb_SG.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb_terra_appsec.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb_SG" {
  name = "terraform-appsec-alb" # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

output "alb_dns_name" {
  value       = aws_lb.alb_terra_appsec.dns_name
  description = "The domain name of the load balancer"
}