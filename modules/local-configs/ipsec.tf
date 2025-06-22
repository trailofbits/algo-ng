resource "random_string" "p12" {
  count            = local.ipsec_count
  length           = 9
  special          = false
  override_special = "/@£$"
}

resource "pkcs12_from_pem" "users" {
  for_each        = local.ipsec_users
  password        = random_string.p12.0.result
  cert_pem        = local.ipsec_config.users.certs[each.key].cert_pem
  private_key_pem = local.ipsec_config.users.keys[each.key].private_key_pem
  encoding        = "legacyRC2"
}

resource "local_sensitive_file" "p12" {
  for_each       = local.ipsec_users
  filename       = "${var.local_path}/ipsec/${each.key}/${each.key}.p12"
  content_base64 = pkcs12_from_pem.users[each.key].result
}

resource "local_file" "ca_cert" {
  count    = local.ipsec_count
  filename = "${var.local_path}/ipsec/ca.crt"
  content  = local.ipsec_config.ca_cert_pem
}

resource "local_file" "server_cert" {
  count    = local.ipsec_count
  filename = "${var.local_path}/ipsec/server.crt"
  content  = local.ipsec_config.server_cert_pem
}

resource "local_file" "user_cert" {
  for_each = local.ipsec_users
  filename = "${var.local_path}/ipsec/${each.key}/${each.key}.crt"
  content  = local.ipsec_config.users.certs[each.key].cert_pem
}

resource "local_sensitive_file" "user_key" {
  for_each = local.ipsec_users
  filename = "${var.local_path}/ipsec/${each.key}/${each.key}.key.pem"
  content  = local.ipsec_config.users.keys[each.key].private_key_pem
}

resource "random_uuid" "mobileconfig" {
  count = var.algo_config.ipsec.enabled ? 5 : 0
}

resource "local_sensitive_file" "mobileconfig" {
  for_each = local.ipsec_users
  filename = "${var.local_path}/ipsec/${each.key}/${each.key}.mobileconfig"

  content = templatefile(
    "${path.module}/templates/ipsec.mobileconfig",
    {
      user                   = each.key,
      remote                 = var.cloud_config.server_ip
      name                   = "AlgoVPN-${var.init_config.deploy_id}-${var.cloud_config.server_ip}"
      id                     = var.init_config.deploy_id
      p12_password           = random_string.p12.0.result
      PayloadCertificateUUID = upper(random_uuid.mobileconfig.0.result)
      VPN_PayloadUUID        = upper(random_uuid.mobileconfig.1.result)
      CA_PayloadUUID         = upper(random_uuid.mobileconfig.2.result)
      PayloadIdentifier      = upper(random_uuid.mobileconfig.3.result)
      PayloadUUID            = upper(random_uuid.mobileconfig.4.result)
      CA_PayloadContent      = base64encode(trimspace(local.ipsec_config.ca_cert_pem))
      P12_PayloadContent     = pkcs12_from_pem.users[each.key].result
    }
  )
}
