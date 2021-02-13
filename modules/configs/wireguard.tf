# data "external" "wg-server-pub" {
#   depends_on = [null_resource.wait-until-deploy-finished]

#   program = [
#     "${path.module}/external/read-file-ssh.sh",
#     "${var.ssh_user}@${var.server_address}",
#     "${var.algo_config}/algo.pem",
#     "/etc/wireguard/.wg-server.pub",
#   ]
# }

# resource "local_file" "wireguard" {
#   count    = var.config.wireguard.enabled ? length(var.config.vpn_users) : 0
#   filename = "${var.algo_config}/wireguard/${var.config.vpn_users[count.index]}.conf"

#   content = templatefile("${path.module}/files/wireguard.conf", {
#     vars = {
#       private_key = base64encode(var.pki.wireguard.client_private_keys[count.index])
#       address     = "${cidrhost(var.config.wireguard.ipv4, 2 + count.index)}/32${var.ipv6 == 0 ? "" : ",${cidrhost(var.config.wireguard.ipv6, 2 + count.index)}/128"}"
#       dns         = join(",", (var.config.dns.encryption.enabled || var.config.dns.adblocking.enabled ? values(var.config.wireguard_dns) : concat(var.config.dns.resolvers.ipv4, var.ipv6 ? var.config.dns.resolvers.ipv6 : [])))
#       peer = {
#         publickey            = var.config.wireguard.enabled
#         endpoint             = "${var.server_address}:${var.config.wireguard.port}"
#         persistent_keepalive = var.config.wireguard.persistent_keepalive > 0 ? var.config.wireguard.persistent_keepalive : 0
#       }
#     }
#     }
#   )
# }
