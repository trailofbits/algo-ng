terraform {
  required_version = "~> 0.12"

  required_providers {
    aws = "~> 2.22"
  }
}

# Does not work as a module if the provider is specified here.
# provider "aws" {
#   region = var.config.clouds.ec2.region
# }
