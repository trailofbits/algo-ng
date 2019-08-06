config = {
  # This is the list of users to generate.
  # Every device must have a unique username.
  vpn_users = [
    "phone",
    "laptop",
    "desktop"
  ]

  # Deploy StrongSwan to enable IPsec support
  ipsec = {
    enabled = true
    ipv4    = "10.100.0.0/16"
    ipv6    = "fd9d:bc11:4020::/64"
  }

  # Deploy WireGuard
  wireguard = {
    enabled = false
    ipv4    = "10.200.0.0/16"
    ipv6    = "fd9d:bc11:4021::/64"
    port    = 51820
    # If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent.
    # This option will keep the "connection" open in the eyes of NAT.
    # See: https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence
    persistent_keepalive = 0
  }

  dns = {
    adblocking = {
      enabled = true

      lists = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
        "https://hosts-file.net/ad_servers.txt"
      ]
    }

    encryption = {
      # Enable DNS encryption.
      # If 'false', resolvers should be specified below.
      # Can not be disable if adblocking is enabled
      enabled = true

      # DNS servers which will be used if dns encryption is enabled. Multiple
      # providers may be specified, but avoid mixing providers that filter results
      # (like Cisco) with those that don't (like Cloudflare) or you could get
      # inconsistent results. The list of available public providers can be found
      # here:
      # https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v2/public-resolvers.md
      servers = {
        ipv4 = [
          "cloudflare"
        ]
        ipv6 = [
          "cloudflare-ipv6"
        ]
      }
    }

    # DNS resolvers which will be used if dns encryption is disabled
    # The default is to use Cloudflare.
    resolvers = {
      ipv4 = [
        "1.1.1.1",
        "1.0.0.1"
      ]

      ipv6 = [
        "2606:4700:4700::1111",
        "2606:4700:4700::1001"
      ]
    }
  }

  ssh_tunneling = true

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

  # Block traffic between connected clients
  drop_traffic_between_clients = true

  # StrongSwan log level
  # https://wiki.strongswan.org/projects/strongswan/wiki/LoggerConfiguration
  strongswan_log_level = "2"

  # Your Algo server will automatically install security updates. Some updates
  # require a reboot to take effect but your Algo server will not reboot itself
  # automatically unless you change 'enabled' below from 'false' to 'true', in
  # which case a reboot will take place if necessary at the time specified (as
  # HH:MM) in the time zone of your Algo server. The default time zone is UTC.
  unattended_reboot = {
    enabled = false
    time    = "06:00"
  }

  # TODO: delete ssh authorized keys
  unmanaged = false

  # Upgrade the system during the deployment
  system_upgrade = true

  ciphers = {
    ipsec = {
      ike = "aes256gcm16-prfsha512-ecp384!"
      esp = "aes256gcm16-ecp384!"
    }
  }
}
