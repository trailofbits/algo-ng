module "user-data" {
  source         = "../../modules/user-data/"
  ssh_public_key = var.ssh_public_key
}
