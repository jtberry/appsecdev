# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_configuration" "appsec-ec2" {
  image_id        = data.aws_ami.amazon-linux-2.id
  instance_type   = var.ami_size
  security_groups = [aws_security_group.http_access.id]
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted = true
  }
  user_data = <<-EOF
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
  #availability_zones = ["us-west-2a"]

  min_size = 1
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terr-web-app-ASG"
    propagate_at_launch = true
  }
}