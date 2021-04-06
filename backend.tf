terraform {
  backend "s3" {
    bucket = "blackdevs-aws"
    key    = "terraform/tf-asg-web-server-alb/state.tfstate"
    region = "sa-east-1"
  }
}
