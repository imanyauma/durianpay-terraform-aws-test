# Variables
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-012967cc5a8c9f891" # Amazon Linux 2023 AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "public-subnet-1" {
  
}

variable "vpc_id" {
  
}

variable "asg_name" {
  
}

variable "email_address" {
  type        = list(string)
  description = "List of email addresses to receive email alert"
  default     = ["yomski@yopmail.com"]
}