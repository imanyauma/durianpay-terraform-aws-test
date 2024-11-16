# Security Group
resource "aws_security_group" "durianpay_sg" {
  name_prefix = "durianpay-sg-"
  description = "Security group for EC2 instances in Auto Scaling Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "asg-security-group"
  }
  vpc_id = var.vpc_id
}

data "template_file" "test" {
  template = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y httpd.x86_64
  sudo systemctl start httpd.service
  sudo systemctl enable httpd.service
  instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
  instanceAZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
  pubHostName=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
  pubIPv4=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
  privHostName=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
  privIPv4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  
  echo "<font face = "Verdana" size = "5">"                               > /var/www/html/index.html
  echo "<center><h1>AWS Linux VM Deployed with Terraform</h1></center>"   >> /var/www/html/index.html
  echo "<center> <b>EC2 Instance Metadata</b> </center>"                  >> /var/www/html/index.html
  echo "<center> <b>Instance ID:</b> $instanceId </center>"                      >> /var/www/html/index.html
  echo "<center> <b>AWS Availablity Zone:</b> $instanceAZ </center>"             >> /var/www/html/index.html
  echo "<center> <b>Public Hostname:</b> $pubHostName </center>"                 >> /var/www/html/index.html
  echo "<center> <b>Public IPv4:</b> $pubIPv4 </center>"                         >> /var/www/html/index.html
  echo "<center> <b>Private Hostname:</b> $privHostName </center>"               >> /var/www/html/index.html
  echo "<center> <b>Private IPv4:</b> $privIPv4 </center>"                       >> /var/www/html/index.html
  echo "</font>"                                                          >> /var/www/html/index.html
EOF
}

# Launch Template
resource "aws_launch_template" "durianpay_lt" {
  name_prefix   = "durianpay-test-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.durianpay_sg.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "durianpay-test-asg-instance"
  }
  user_data = base64encode("${data.template_file.test.rendered}")
}

# Auto Scaling Group
resource "aws_autoscaling_group" "durianpay_asg" {
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier  = [var.public-subnet-1]
  launch_template {
    id      = aws_launch_template.durianpay_lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "durianpay-test-instance"
    propagate_at_launch = true
  }
}

# Auto Scaling Policies (Optional)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.durianpay_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.durianpay_asg.name
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60" #seconds
  statistic                 = "Average"
  threshold                 = "45"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.topic.arn]
  alarm_name =  "Durianpay CPU Metric"
  # dimensions = {
  #   InstanceId = module.aws_ec2.instance_id
  # }
}

resource "aws_sns_topic" "topic" {
  name = "WebServer-CPU_Utilization_alert"
  tags = {
    "Name" = "SNS Topic"
  }
}

resource "aws_sns_topic_subscription" "topic_email_subscription" {
  count     = length(var.email_address)
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.email_address[count.index]
}

