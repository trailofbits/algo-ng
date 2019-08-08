terraform {
  required_version = "~> 0.12"

  required_providers {
    google = "~> 2.6"
  }
}

provider "google" {
  region  = var.config.clouds.gce.region
  project = jsondecode(file(var.google_credentials))["project_id"]
}
