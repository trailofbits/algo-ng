terraform {
  required_version = ">= 0.12"
}

provider "local" {
  version = "~> 1.2"
}

provider "external" {
  version = "~> 1.1"
}

provider "null" {
  version = "~> 2.1"
}
