terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source = "hashicorp/local"
    }

    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

provider "aws" {
  region = var.config.clouds.ec2.region
}

provider "aws" {
  alias  = "lightsail"
  region = replace(var.config.clouds.lightsail.availability_zone, "/[a-z]$/", "")
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.config.clouds.gce.project
}

provider "scaleway" {
  region = var.config.clouds.scaleway.region
}
