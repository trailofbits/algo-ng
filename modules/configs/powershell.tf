locals {
  powershell = {
    ondemand            = var.ondemand
    vpn_users           = var.vpn_users
    server_address      = var.server_address
    algo_config         = var.algo_config
    CaCertificateBase64 = base64encode(var.pki.ipsec.ca_cert)
  }
}

# resource "local_file" "powershell" {
#   count    = length(var.vpn_users)
#   content  = templatefile("${path.module}/files/powershell.ps1", { var = local.powershell, index = count.index, pki = var.pki })
#   filename = "${var.algo_config}/ipsec/windows/${var.vpn_users[count.index]}.ps1"
# }
