
terraform {
  required_version = ">= 0.12"
}

provider "template" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.1"
}

provider "external" {
  version = "~> 1.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "tls" {
  version = "~> 2.0"
}

provider "digitalocean" {
  version = "~> 1.2"
}
