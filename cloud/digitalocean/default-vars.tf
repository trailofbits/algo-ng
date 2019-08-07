variable "region" {
  default = "nyc1"
}

terraform {
  required_providers {
    digitalocean = "~> 1.3"
  }
}
