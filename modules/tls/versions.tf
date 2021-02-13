terraform {
  required_version = ">= 0.14"
  required_providers {
    external = {
      source = "hashicorp/external"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
    tls-x25519 = {
      source = "jackivanov/tls"
    }
  }
}
