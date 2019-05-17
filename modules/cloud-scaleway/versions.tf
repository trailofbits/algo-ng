terraform {
  required_version = "~> 0.12"
}

provider "scaleway" {
  region = "${var.region}"
}
