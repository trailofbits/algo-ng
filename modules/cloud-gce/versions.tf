terraform {
  required_version = "~> 0.12"
}

provider "google" {
  region  = var.region
  project = jsondecode(file(var.google_credentials))["project_id"]
  version = "~> 2.6"
}
