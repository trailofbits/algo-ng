config = {
  cloud = "lightsail"

  # This is the list of users to generate.
  # Every device must have a unique username.
  vpn_users = [
    "phone",
    "laptop",
    "desktop",
  ]

  # Deploy WireGuard
  wireguard = {
    ipv4 = "10.49.0.0/16"
    ipv6 = "2001:db8:a160::/48"
    port = 51820

    # should be consistent with the ipv4 max hosts
    # `ipcalc 10.49.0.0/16` - 1
    max_hosts = 65533

    # If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent.
    # This option will keep the "connection" open in the eyes of NAT.
    # See: https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence
    persistent_keepalive = 0
  }

  # Reduce the MTU of the VPN tunnel
  # Some cloud and internet providers use a smaller MTU (Maximum Transmission
  # Unit) than the normal value of 1500 and if you don't reduce the MTU of your
  # VPN tunnel some network connections will hang. Algo will attempt to set this
  # automatically based on your server, but if connections hang you might need to
  # adjust this yourself.
  # See: https://github.com/trailofbits/algo/blob/master/docs/troubleshooting.md#various-websites-appear-to-be-offline-through-the-vpn
  reduce_mtu = 0

  ssh_tunneling = {
    enabled = true
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
        ],
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

  # Block traffic between connected clients
  block_traffic_between_clients = true
  block_smb                     = true

  # Your Algo server will automatically install security updates. Some updates
  # require a reboot to take effect but your Algo server will not reboot itself
  # automatically unless you change 'enabled' below from 'false' to 'true', in
  # which case a reboot will take place if necessary at the time specified (as
  # HH:MM) in the time zone of your Algo server. The default time zone is UTC.
  unattended_reboot = {
    enabled = true
    time    = "06:00"
  }

  # TODO: delete ssh authorized keys
  unmanaged = false

  clouds = {
    digitalocean = {
      image  = "ubuntu-20-04-x64"
      size   = "s-1vcpu-1gb"
      region = "fra1"
      ipv6   = true
    }

    ec2 = {
      image      = "ubuntu-focal-20.04"
      size       = "t2.micro"
      region     = "us-east-1"
      ipv6       = true
      encrypted  = true
      kms_key_id = null
    }

    lightsail = {
      image             = "ubuntu_20_04"
      size              = "nano_2_0"
      availability_zone = "us-east-1a"
      ipv6              = true
    }

    azure = {
      image  = "20.04"
      size   = "Standard_B1S"
      region = "eastus"
    }

    gce = {
      image  = "ubuntu-os-cloud/ubuntu-2004"
      size   = "f1-micro"
      region = "us-east1"
    }
  }
}
