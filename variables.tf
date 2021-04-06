# AWS variables
variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "sa-east-1"
}

variable "aws_azs" {
  type        = list(string)
  description = "Availability zones inside aws_region"
  default     = ["a", "b", "c"]
}

variable "aws_instance_size" {
  type        = string
  description = "AWS instance size"
  default     = "t2.micro"
}

variable "aws_instance_role" {
  type        = string
  description = "AWS instance IAM role"
  default     = "AmazonEC2Role"
}

variable "aws_instance_asg_options" {
  type        = map
  description = "AWS ASG options for on-demand instances"
  default = {
    desired_capacity = 1
    min_size         = 1
    max_size         = 2
  }
}

variable "aws_spot_asg_options" {
  type        = map
  description = "AWS ASG options for spot instances"
  default = {
    desired_capacity = 2
    min_size         = 2
    max_size         = 4
  }
}

variable "root_domain" {
  type        = string
  description = "The root domain on AWS"
}

variable "certificate_arn" {
  type        = string
  description = "The certificate ARN on AWS"
}
