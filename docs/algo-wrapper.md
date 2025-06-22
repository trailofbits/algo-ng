# Algo Wrapper Script

This Python script is a command-line wrapper around OpenTofu designed to simplify managing VPN infrastructure deployments.

```bash
./algo --help
usage: algo [-h] [--provider {DigitalOcean,Lightsail,EC2,GCE,Azure}] [--workspace WORKSPACE] [--destroy] [--update-users] [--ondemand-cellular ONDEMAND_CELLULAR] [--ondemand-wifi ONDEMAND_WIFI]
            [--ondemand-wifi-exclude ONDEMAND_WIFI_EXCLUDE] [--dns-adblocking DNS_ADBLOCKING] [--ssh-tunneling SSH_TUNNELING] [--state-pass STATE_PASS] [--skip-init] [--auto-approve]
            [--config-file CONFIG_FILE]

Manage VPN setup with OpenTofu.

options:
  -h, --help            show this help message and exit
  --provider {DigitalOcean,Lightsail,EC2,GCE,Azure}
                        Provider name
  --workspace WORKSPACE
                        Specify the workspace
  --destroy             Destroy the infrastructure and exit
  --update-users        Update VPN users without modifying infrastructure
  --ondemand-cellular ONDEMAND_CELLULAR
                        Enable 'Connect On Demand' on cellular? [y/N]
  --ondemand-wifi ONDEMAND_WIFI
                        Enable 'Connect On Demand' on Wi-Fi? [y/N]
  --ondemand-wifi-exclude ONDEMAND_WIFI_EXCLUDE
                        Exclude trusted Wi-Fi networks (comma-separated)
  --dns-adblocking DNS_ADBLOCKING
                        Enable DNS Ad Blocking? [y/N]
  --ssh-tunneling SSH_TUNNELING
                        Enable SSH Tunneling? [y/N]
  --state-pass STATE_PASS
                        State passphrase for encryption (optional, will prompt if not set)
  --skip-init           Skip the tofu init and only run apply
  --auto-approve        Automatically approve changes without prompting for confirmation
  --config-file CONFIG_FILE
                        Path to Algo configuration file
```

## What it does

- **Interactive provider and workspace selection:**
  Lists available workspaces and lets you select or create one. Also lets you pick the cloud provider (DigitalOcean, Lightsail, EC2, GCE, Azure).

- **Manages sensitive state encryption:**
  Prompts for a state encryption passphrase (minimum 16 characters) to protect the local state file. This helps keep your infrastructure secrets safe.

- **Flexible configuration options:**
  Lets you enable or disable features like "Connect On Demand" for cellular/Wi-Fi, DNS ad blocking, SSH tunneling, and specify trusted Wi-Fi exclusions.

- **Supports infrastructure lifecycle:**
  Easily create, update, or destroy your VPN setup with simple flags like `--destroy` or `--update-users`.

- **Stores configuration:**
  Saves environment variables into a workspace-specific JSON file (`algo.tfvars.json`) for consistent runs.

- **Runs OpenTofu commands:**
  Handles running `init`, `apply`, and `destroy` commands with the right variables and workspace context, automating the usual Terraform/OpenTofu steps.

- **Debug mode:**
  Enable detailed debug output by setting `ALGO_DEBUG=1` in your environment.

## Prerequisites

Before running the wrapper, make sure you have the following in place:

- **Python 3.x** installed on your system.
- The **OpenTofu CLI** (`tofu`) installed and available in your system’s `PATH`.
  → See installation instructions at: [https://opentofu.org/docs/intro/install/](https://opentofu.org/docs/intro/install/)
- Proper **cloud provider credentials** configured (e.g., AWS keys, DigitalOcean tokens, etc.)
  → Follow our guide: [`docs/clouds-credentials.md`](../docs/clouds-credentials.md)

## Environment Variables

- `ALGO_DEBUG=1`
  Enable debug output to see detailed logs during script execution, helpful for troubleshooting.

- `TF_VAR_state_passphrase`
  Optionally provide your Terraform/OpenTofu state encryption passphrase through this environment variable to avoid interactive prompts.

## Example Commands

Run the script with interactive prompts:

```bash
./algo
```

Run the script non-interactively with all options specified:

```bash
./algo --provider Lightsail --ondemand-cellular N --ondemand-wifi N --dns-adblocking y --ssh-tunneling y --skip-init --auto-approve
```

Destroy your infrastructure:

```bash
./algo.py --destroy --provider Lightsail
```

Update VPN users without changing infrastructure:

```bash
./algo.py
```
