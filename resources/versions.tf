terraform {
  required_version = ">= 1.4"

  required_providers {
    local = {
      source = "hashicorp/local"
    }

    x25519 = {
      source  = "jackivanov/x25519"
      version = ">= 1.0"
    }
  }
}

provider "x25519" {}
