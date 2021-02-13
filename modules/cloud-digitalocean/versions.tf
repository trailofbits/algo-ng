terraform {
  required_version = ">= 0.14"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.2"
    }

    tls = {
      source  = "jackivanov/tls"
      version = "~> 3.1.5"
    }
  }
}
