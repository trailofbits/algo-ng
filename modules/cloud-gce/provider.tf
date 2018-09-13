provider "google" {
  region  = "${var.region}"
  version = "~> 1.17"
}

provider "random" {
  version = "~> 2.0"
}
