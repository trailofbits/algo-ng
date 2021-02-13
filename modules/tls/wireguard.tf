resource "tls_x25519" "wg_client" {
  provider = tls-x25519
  for_each = toset(var.vpn_users)
}
