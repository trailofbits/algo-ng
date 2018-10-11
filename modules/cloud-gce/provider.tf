data "external" "google_credentials" {
  program = ["cat", "${var.google_credentials}"]
}

provider "google" {
  region  = "${var.region}"
  project = "${data.external.google_credentials.result["project_id"]}"
  version = "~> 1.17"
}

provider "random" {
  version = "~> 2.0"
}
