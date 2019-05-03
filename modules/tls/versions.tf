terraform {
  required_version = ">= 0.12"
}

provider "tls" {
  version = "~> 2.0"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.1"
}
