# resource "random_string" "p12" {
#   count            = local.algo_config.ipsec.enabled ? 1 : 0
#   length           = 9
#   special          = false
#   override_special = "/@£$"
# }

# resource "pkcs12_from_pem" "users" {
#   for_each        = local.ipsec_users
#   password        = random_string.p12.0.result
#   cert_pem        = local.ipsec_config.users.certs[each.key].cert_pem
#   private_key_pem = local.ipsec_config.users.keys[each.key].private_key_pem
#   encoding        = "legacyRC2"
# }

# resource "local_sensitive_file" "p12" {
#   for_each       = local.ipsec_users
#   filename       = "${local.local_config}/ipsec/manual/${each.key}.p12"
#   content_base64 = pkcs12_from_pem.users[each.key].result
# }

# resource "local_file" "ca_cert" {
#   count    = local.algo_config.ipsec.enabled ? 1 : 0
#   filename = "${local.local_config}/ipsec/manual/ca.pem"
#   content  = local.ipsec_config.ca_cert_pem
# }

# resource "local_file" "server_cert" {
#   count    = local.algo_config.ipsec.enabled ? 1 : 0
#   filename = "${local.local_config}/ipsec/manual/server.pem"
#   content  = local.ipsec_config.server_cert_pem
# }

# resource "local_file" "user_cert" {
#   for_each = local.ipsec_users
#   filename = "${local.local_config}/ipsec/manual/${each.key}.crt.pem"
#   source   = local.ipsec_config.users.certs[each.key].cert_pem
# }

# resource "local_sensitive_file" "user_key" {
#   for_each = local.ipsec_users
#   filename = "${local.local_config}/ipsec/manual/${each.key}.key.pem"
#   source   = local.ipsec_config.users.keys[each.key].private_key_pem
# }

# resource "random_uuid" "mobileconfig" {
#   count = local.algo_config.ipsec.enabled ? 5 : 0
# }

# resource "local_sensitive_file" "mobileconfig" {
#   for_each = local.ipsec_users
#   filename = "${local.local_config}/ipsec/apple/${each.key}.mobileconfig"

#   source = templatefile(
#     "${path.module}/templates/ipsec.mobileconfig",
#     {
#       user                   = each.key,
#       remote                 = local.cloud_config.remote.server_ip
#       name                   = "algovpn-${local.init_config.deploy_id}-${local.cloud_config.remote.server_ip}"
#       id                     = local.init_config.deploy_id
#       p12_password           = random_string.p12.0.result
#       PayloadCertificateUUID = upper(random_uuid.mobileconfig.0.result)
#       VPN_PayloadUUID        = upper(random_uuid.mobileconfig.1.result)
#       CA_PayloadUUID         = upper(random_uuid.mobileconfig.2.result)
#       PayloadIdentifier      = upper(random_uuid.mobileconfig.3.result)
#       PayloadUUID            = upper(random_uuid.mobileconfig.4.result)
#       CA_PayloadContent      = base64encode(trimspace(local.ipsec_config.ca_cert_pem))
#       P12_PayloadContent     = pkcs12_from_pem.users[each.key].result
#     }
#   )
# }
