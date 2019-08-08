terraform {
  required_version = "~> 0.12"

  required_providers {
    aws = "~> 2.22"
  }
}

provider "aws" {
  region = var.config.clouds.ec2.region
}
