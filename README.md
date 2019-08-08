# Algo VPN

[![Join the chat at https://gitter.im/trailofbits/algo](https://badges.gitter.im/trailofbits/algo.svg)](https://gitter.im/trailofbits/algo?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Twitter](https://img.shields.io/twitter/url/https/twitter.com/fold_left.svg?style=social&label=Follow%20%40AlgoVPN)](https://twitter.com/AlgoVPN)
[![TravisCI Status](https://api.travis-ci.org/trailofbits/algo-ng.svg?branch=master)](https://travis-ci.org/trailofbits/algo-ng)

Algo VPN is a set of Terraform files that simplify the setup of a personal VPN. It uses the most secure defaults available, works with common cloud providers, and does not require client software on most devices. See our [release announcement](https://blog.trailofbits.com/2016/12/12/meet-algo-the-vpn-that-works/) for more information.

## Features

* Supports only IKEv2 with strong crypto (AES-GCM, SHA2, and P-256) and [WireGuard](https://www.wireguard.com/)
* Generates Apple profiles to auto-configure iOS and macOS devices
* Includes a helper script to add and remove users
* Blocks ads with a local DNS resolver (optional)
* Sets up limited SSH users for tunneling traffic (optional)
* Based on current versions of Ubuntu and StrongSwan
* Installs to DigitalOcean, Amazon Lightsail, Amazon EC2, Microsoft Azure, Google Compute Engine, Hetzner, Scaleway

## Anti-features

* Does not support legacy cipher suites or protocols like L2TP, IKEv1, or RSA
* Does not install Tor, OpenVPN, or other risky servers
* Does not depend on the security of [TLS](https://tools.ietf.org/html/rfc7457)
* Does not require client software on most platforms
* Does not claim to provide anonymity or censorship avoidance
* Does not claim to protect you from the [FSB](https://en.wikipedia.org/wiki/Federal_Security_Service), [MSS](https://en.wikipedia.org/wiki/Ministry_of_State_Security_(China)), [DGSE](https://en.wikipedia.org/wiki/Directorate-General_for_External_Security), or [FSM](https://en.wikipedia.org/wiki/Flying_Spaghetti_Monster)

## Deploy the Algo Server

The easiest way to get an Algo server running is to let it set up a _new_ virtual machine in the cloud for you.

1. **Setup an account on a cloud hosting provider.** Algo supports [DigitalOcean](https://m.do.co/c/4d7f4ff9cfe4) (most user friendly), [Amazon EC2](https://aws.amazon.com/), [Google Compute Engine](https://cloud.google.com/compute/), and [Microsoft Azure](https://azure.microsoft.com/).

2. **[Download Algo](https://github.com/trailofbits/algo-ng/archive/master.zip).** Unzip it in a convenient location on your local machine.

3. **Install Algo's core dependencies.** Open the Terminal.

    - macOS:
      ```bash
      $ brew install terraform
      ```

    - Ubuntu (16.04 or later):
      ```bash
      $ sudo apt-get update && sudo apt-get install snapd -y \
      $ sudo snap install terraform
      ```

    - Others:  **[Download Terraform binary](https://www.terraform.io/downloads.html)**

4. **List the users to create.** Open `config.auto.tfvars` in your favorite text editor. Specify the users you wish to create in the `vpn_users` list.

5. **Start the deployment.** Return to your terminal. In the Algo directory, run `./algo apply` and follow the instructions. There are several optional features available. None are required for a fully functional VPN server.

That's it! You will get the message below when the server deployment process completes. You now have an Algo server on the internet. Take note of the p12 (user certificate) password in case you need it later.

You can now setup clients to connect it, e.g. your iPhone or laptop. Proceed to [Configure the VPN Clients](#configure-the-vpn-clients) below.

## Configure the VPN Clients

Certificates and configuration files that users will need are placed in the `configs` directory. Make sure to secure these files since many contain private keys. All files are saved under a subdirectory named with the IP address of your new Algo VPN server.

### Apple Devices

**Send users their Apple Profile.** Find the corresponding mobileconfig (Apple Profile) for each user and send it to them over AirDrop or other secure means. Apple Configuration Profiles are all-in-one configuration files for iOS and macOS devices. On macOS, double-clicking a profile to install it will fully configure the VPN. On iOS, users are prompted to install the profile as soon as the AirDrop is accepted.

**Turn on the VPN.** On iOS, connect to the VPN by opening Settings and clicking the toggle next to "VPN" near the top of the list. On macOS, connect to the VPN by opening System Preferences -> Network, finding Algo VPN in the left column and clicking "Connect." On macOS, check "Show VPN status in menu bar" to easily connect and disconnect from the menu bar.

**Managing On-Demand VPNs.** If you enabled "On Demand", the VPN will connect automatically whenever it is able. On iOS, you can turn off "On Demand" by clicking the (i) next to the entry for Algo VPN and toggling off "Connect On Demand." On macOS, you can turn off "On Demand" by opening the Network Preferences, finding Algo VPN in the left column, and unchecking the box for "Connect on demand."

### Android Devices

WireGuard is used to provide VPN services on Android. Install the [WireGuard VPN Client](https://play.google.com/store/apps/details?id=com.wireguard.android). Import the corresponding `wireguard/<name>.conf` file to your device, then setup a new connection with it. See the [Android setup instructions](/docs/client-android.md) for more detailed walkthrough.

### Windows

WireGuard is used to provide VPN services on Windows. Algo generates a WireGuard configuration file, `wireguard/<username>.conf`, for each user defined in `config.cfg`.

Install the [WireGuard VPN Client](https://www.wireguard.com/install/#windows-7-8-81-10-2012-2016-2019). Import the generated `wireguard/<username>.conf` file to your device, then setup a new connection with it.

### Linux Network Manager Clients (e.g., Ubuntu, Debian, or Fedora Desktop)

Network Manager does not support AES-GCM. In order to support Linux Desktop clients, choose the "compatible" cryptography during the deploy process and use at least Network Manager 1.4.1. See [Issue #263](https://github.com/trailofbits/algo/issues/263) for more information.

### Linux strongSwan Clients (e.g., OpenWRT, Ubuntu Server, etc.)

Install strongSwan, then copy the included ipsec_user.conf, ipsec_user.secrets, user.crt (user certificate), and user.key (private key) files to your client device. These will require customization based on your exact use case. These files were originally generated with a point-to-point OpenWRT-based VPN in mind.

#### Ubuntu Server example

1. `sudo apt-get install strongswan libstrongswan-standard-plugins`: install strongSwan
2. `/etc/ipsec.d/certs`: copy `<name>.crt` from `algo-master/configs/<server_ip>/ipsec/manual/<name>.crt`
3. `/etc/ipsec.d/private`: copy `<name>.key` from `algo-master/configs/<server_ip>/ipsec/manual/<name>.key`
4. `/etc/ipsec.d/cacerts`: copy `cacert.pem` from `algo-master/configs/<server_ip>/ipsec/manual/cacert.pem`
5. `/etc/ipsec.secrets`: add your `user.key` to the list, e.g. `<server_ip> : ECDSA <name>.key`
6. `/etc/ipsec.conf`: add the connection from `ipsec_user.conf` and ensure `leftcert` matches the `<name>.crt` filename
7. `sudo ipsec restart`: pick up config changes
8. `sudo ipsec up <conn-name>`: start the ipsec tunnel
9. `sudo ipsec down <conn-name>`: shutdown the ipsec tunnel

One common use case is to let your server access your local LAN without going through the VPN. Set up a passthrough connection by adding the following to `/etc/ipsec.conf`:

    conn lan-passthrough
    leftsubnet=192.168.1.1/24 # Replace with your LAN subnet
    rightsubnet=192.168.1.1/24 # Replace with your LAN subnet
    authby=never # No authentication necessary
    type=pass # passthrough
    auto=route # no need to ipsec up lan-passthrough

To configure the connection to come up at boot time replace `auto=add` with `auto=start`.

### Other Devices

Depending on the platform, you may need one or multiple of the following files.

* ipsec/manual/cacert.pem: CA Certificate
* ipsec/manual/<user>.p12: User Certificate and Private Key (in PKCS#12 format)
* ipsec/manual/<user>.conf: strongSwan client configuration
* ipsec/manual/<user>.secrets: strongSwan client configuration
* ipsec/apple/<user>.mobileconfig: Apple Profile
* wireguard/<user>.conf: WireGuard configuration profile
* wireguard/<user>.png: WireGuard configuration QR code

## Setup an SSH Tunnel

If you turned on the optional SSH tunneling role, then local user accounts will be created for each user in `config.cfg` and SSH authorized_key files for them will be in the `configs` directory (user.ssh.pem). SSH user accounts do not have shell access, cannot authenticate with a password, and only have limited tunneling options (e.g., `ssh -N` is required). This ensures that SSH users have the least access required to setup a tunnel and can perform no other actions on the Algo server.

Use the example command below to start an SSH tunnel by replacing `user` and `ip` with your own. Once the tunnel is setup, you can configure a browser or other application to use 127.0.0.1:1080 as a SOCKS proxy to route traffic through the Algo server.

 `ssh -D 127.0.0.1:1080 -f -q -C -N user@ip -i configs/<server_ip>/ssh-tunnel/<user>.pem`

## SSH into Algo Server

Your Algo server is configured for key-only SSH access for administrative purposes. Open the Terminal app, `cd` into the `algo-master` directory where you originally downloaded Algo, and then use the command listed on the success message:

 `ssh -i configs/algo.pem user@ip`

where `user` is either `root` or `ubuntu` as listed on the success message, and `ip` is the IP address of your Algo server. If you find yourself regularly logging into the server then it will be useful to load your Algo ssh key automatically. Add the following snippet to the bottom of `~/.bash_profile` to add it to your shell environment permanently.

 `ssh-add ~/.ssh/algo > /dev/null 2>&1`

## Adding or Removing Users

If you chose the save the CA certificate during the deploy process, then Algo's own scripts can easily add and remove users from the VPN server.

1. Update the `vpn_users` list in your `config.auto.tfvars`
2. Open a terminal, `cd` to the algo directory, and run the command: `./algo update-users`

After this process completes, the Algo VPN server will contains only the users listed in the `config.auto.tfvars` file.

## Additional Documentation
* [Deployment instructions, cloud provider setup instructions, and further client setup instructions available here.](docs/index.md)
* [FAQ](docs/faq.md)
* [Troubleshooting](docs/troubleshooting.md)

If you read all the documentation and have further questions, [join the chat on Gitter](https://gitter.im/trailofbits/algo).

## Endorsements

> I've been ranting about the sorry state of VPN svcs for so long, probably about
> time to give a proper talk on the subject. TL;DR: use Algo.

-- [Kenn White](https://twitter.com/kennwhite/status/814166603587788800)

> Before picking a VPN provider/app, make sure you do some research
> https://research.csiro.au/ng/wp-content/uploads/sites/106/2016/08/paper-1.pdf ... – or consider Algo

-- [The Register](https://twitter.com/TheRegister/status/825076303657177088)

> Algo is really easy and secure.

-- [the grugq](https://twitter.com/thegrugq/status/786249040228786176)

> I played around with Algo VPN, a set of scripts that let you set up a VPN in the cloud in very little time, even if you don’t know much about development. I’ve got to say that I was quite impressed with Trail of Bits’ approach.

-- [Romain Dillet](https://twitter.com/romaindillet/status/851037243728965632) for [TechCrunch](https://techcrunch.com/2017/04/09/how-i-made-my-own-vpn-server-in-15-minutes/)

> If you’re uncomfortable shelling out the cash to an anonymous, random VPN provider, this is the best solution.

-- [Thorin Klosowski](https://twitter.com/kingthor) for [Lifehacker](http://lifehacker.com/how-to-set-up-your-own-completely-free-vpn-in-the-cloud-1794302432)

## Support Algo VPN
[![Flattr](https://button.flattr.com/flattr-badge-large.png)](https://flattr.com/submit/auto?fid=kxw60j&url=https%3A%2F%2Fgithub.com%2Ftrailofbits%2Falgo)
[![PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CYZZD39GXUJ3E)
[![Patreon](https://img.shields.io/badge/back_on-patreon-red.svg)](https://www.patreon.com/algovpn)
[![Bountysource](https://img.shields.io/bountysource/team/trailofbits/activity.svg)](https://www.bountysource.com/teams/trailofbits)

All donations support continued development. Thanks!

* We accept donations via [PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=CYZZD39GXUJ3E), [Patreon](https://www.patreon.com/algovpn), and [Flattr](https://flattr.com/submit/auto?fid=kxw60j&url=https%3A%2F%2Fgithub.com%2Ftrailofbits%2Falgo).
* Use our [referral code](https://m.do.co/c/4d7f4ff9cfe4) when you sign up to Digital Ocean for a $10 credit.
* We also accept and appreciate contributions of new code and bugfixes via Github Pull Requests.

Algo is licensed and distributed under the AGPLv3. If you want to distribute a closed-source modification or service based on Algo, then please consider <a href="mailto:opensource@trailofbits.com">purchasing an exception</a> . As with the methods above, this will help support continued development.
