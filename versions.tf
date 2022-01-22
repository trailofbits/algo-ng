terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "aws" {
  region = var.config.clouds.ec2.region
}
