variable "environment" {
  description = "Deployment environment (aws or localstack)"
  type        = string
  default     = "aws"
}

variable "asg_name" {
  description = "Auto Scaling group Name"
  type = string
  default = "durianpay-test-asg"
}