# TODO: https://github.com/trailofbits/algo/pull/1183
vpn_users = [
  "phone",
  "laptop",
  "desktop"
]

components = {
  "ipsec"           = true
  "wireguard"       = true
  "dns_encryption"  = true
  "dns_adblocking"  = false
  "ssh_tunneling"   = false
  "windows"         = false
}
