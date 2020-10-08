terraform {
  required_version = ">= 0.13"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 1.3"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
