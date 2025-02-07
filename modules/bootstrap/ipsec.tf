# # CA
# resource "tls_private_key" "ca" {
#   count       = local.algo_config.ipsec.enabled ? 1 : 0
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_self_signed_cert" "ca" {
#   count                 = local.algo_config.ipsec.enabled ? 1 : 0
#   private_key_pem       = tls_private_key.ca.0.private_key_pem
#   validity_period_hours = 87600
#   is_ca_certificate     = true

#   subject {
#     common_name = "AlgoVPN-${var.config.init.config.deploy_id}"
#   }

#   allowed_uses = [
#     "cert_signing",
#     "crl_signing",
#   ]
# }

# # Server

# resource "tls_private_key" "server" {
#   count       = local.algo_config.ipsec.enabled ? 1 : 0
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_cert_request" "server" {
#   count           = local.algo_config.ipsec.enabled ? 1 : 0
#   private_key_pem = tls_private_key.server.0.private_key_pem
#   ip_addresses    = [var.config.cloud.remote.server_ip]
#   dns_names       = ["algo.vpn"]

#   subject {
#     common_name = "server"
#   }
# }

# resource "tls_locally_signed_cert" "server" {
#   count              = local.algo_config.ipsec.enabled ? 1 : 0
#   cert_request_pem   = tls_cert_request.server.0.cert_request_pem
#   ca_private_key_pem = tls_private_key.ca.0.private_key_pem
#   ca_cert_pem        = tls_self_signed_cert.ca.0.cert_pem
#   # set_subject_key_id    = true
#   validity_period_hours = 87600

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#     "client_auth"
#   ]
# }

# # Users

# resource "tls_private_key" "users" {
#   for_each    = local.algo_config.ipsec.enabled ? local.users : {}
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_cert_request" "users" {
#   for_each        = local.algo_config.ipsec.enabled ? local.users : {}
#   private_key_pem = tls_private_key.users[each.key].private_key_pem
#   dns_names       = [each.key]


#   subject {
#     common_name = each.key
#   }
# }

# resource "tls_locally_signed_cert" "users" {
#   for_each              = local.algo_config.ipsec.enabled ? local.users : {}
#   cert_request_pem      = tls_cert_request.users[each.key].cert_request_pem
#   ca_private_key_pem    = tls_private_key.ca.0.private_key_pem
#   ca_cert_pem           = tls_self_signed_cert.ca.0.cert_pem
#   set_subject_key_id    = true
#   validity_period_hours = 87600

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#     "client_auth"
#   ]
# }

# locals {
#   ipsec_conns = [
#     for user in local.algo_config.vpn_users : {
#       rightid = user
#     }
#   ]

#   ipsec_conf = templatefile(
#     "${path.module}/templates/strongswan/ipsec.conf", {
#       log_level = local.algo_config.ipsec.log_level
#       ciphers   = local.algo_config.ipsec.ciphers
#       leftid    = var.config.cloud.remote.server_ip

#       rightdns = flatten([
#         local.init_config.dns.ipv4,
#         local.init_config.dns.ipv6
#       ])

#       rightsourceip = [
#         local.algo_config.ipsec.ipv4,
#         local.algo_config.ipsec.ipv6
#       ]

#       ipsec_conns = local.ipsec_conns
#     }
#   )
# }

# resource "null_resource" "strongswan-script" {
#   count = local.algo_config.ipsec.enabled ? 1 : 0

#   connection {
#     type        = "ssh"
#     timeout     = "30m"
#     port        = 22
#     host        = var.config.cloud.remote.server_ip
#     user        = var.config.cloud.remote.ssh_user
#     private_key = var.config.init.config.ssh_private_key
#   }

#   triggers = merge(var.triggers, {
#     ca_cert_pem            = md5(tls_self_signed_cert.ca.0.cert_pem)
#     server_cert_pem        = md5(tls_locally_signed_cert.server.0.cert_pem)
#     server_private_key_pem = md5(tls_private_key.server.0.private_key_pem)
#     ca_private_key_pem     = md5(tls_private_key.ca.0.private_key_pem)
#     ipsec_conf             = md5(local.ipsec_conf)
#   })

#   provisioner "file" {
#     content     = tls_self_signed_cert.ca.0.cert_pem
#     destination = "/opt/algo/configs/strongswan/ca-cert.pem"
#   }

#   provisioner "file" {
#     content     = tls_locally_signed_cert.server.0.cert_pem
#     destination = "/opt/algo/configs/strongswan/server-cert.pem"
#   }

#   provisioner "file" {
#     content     = tls_private_key.server.0.private_key_pem
#     destination = "/opt/algo/configs/strongswan/server-key.pem"
#   }

#   provisioner "file" {
#     content     = local.ipsec_conf
#     destination = "/opt/algo/configs/strongswan/ipsec.conf"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo bash /opt/algo/scripts/strongswan.sh"
#     ]
#   }

#   depends_on = [
#     null_resource.common
#   ]
# }

# output "ipsec_config" {
#   value = {
#     ca_cert_pem     = try(tls_self_signed_cert.ca.0.cert_pem, null)
#     server_cert_pem = try(tls_locally_signed_cert.server.0.cert_pem, null)
#     users = {
#       keys  = tls_private_key.users
#       certs = tls_locally_signed_cert.users
#     }
#   }
# }
