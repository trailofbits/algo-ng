vpn_users = [
  "jack",
  "dan"
]

components = {
  "ipsec"           = true
  "dns_encryption"  = true
  "dns_adblocking"  = true
  "ssh_tunneling"   = false
  "windows"         = true
}

unmanaged = false

# MSS is the TCP Max Segment Size
# Setting the 'max_mss' variable can solve some issues related to packet fragmentation
# This appears to be necessary on (at least) Google Cloud,
# however, some routers also require a change to this parameter
# See also:
# - https://github.com/trailofbits/algo/issues/216
# - https://github.com/trailofbits/algo/issues?utf8=%E2%9C%93&q=is%3Aissue%20mtu
# - https://serverfault.com/questions/601143/ssh-not-working-over-ipsec-tunnel-strongswan
# max_mss = 1316
max_mss = 0

system_upgrade = false
