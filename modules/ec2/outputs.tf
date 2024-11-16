output "asg_name" {
  value = aws_autoscaling_group.durianpay_asg.name
}

output "sg_name" {
  value = aws_security_group.durianpay_sg.name
}