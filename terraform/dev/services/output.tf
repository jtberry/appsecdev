output "alb_dns_name" {
  value       = aws_lb.alb_appsec.dns_name
  description = "The domain name of the load balancer"
}

output "aws_autoscaling_group"{
  value = aws_autoscaling_group.scaling_ec2.availability_zones
}

output "security_group_id" {
  description = "id of SG"
  value       = aws_security_group.alb_SG.id
}