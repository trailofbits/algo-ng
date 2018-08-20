provider "google" {
  region  = "${var.region}"
  project = "${var.project}"
  version = "~> 1.8"
}
