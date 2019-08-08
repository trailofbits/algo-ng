# TODO: revise the way we generate private keys for WireGuard
# EdDSA/Ed25519 is not implemented in Terraform yet
# https://github.com/terraform-providers/terraform-provider-tls/issues/26
resource "random_string" "wg_server_private_key" {
  length  = 32
  special = true
}

resource "random_string" "wg_client_private_key" {
  count   = length(var.vpn_users)
  length  = 32
  special = true
}
