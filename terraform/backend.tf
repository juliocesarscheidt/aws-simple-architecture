terraform {
  backend "s3" {
    bucket               = "blackdevs-aws"
    key                  = "state.tfstate"
    region               = "sa-east-1"
    workspace_key_prefix = "terraform/aws-simple-architecture"
  }
}
