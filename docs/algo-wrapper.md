# Algo Wrapper Script

This Python script is a command-line wrapper around OpenTofu designed to simplify managing VPN infrastructure deployments.

---

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

---

## Prerequisites

Before running the wrapper, make sure you have the following in place:

- **Python 3.x** installed on your system.
- The **OpenTofu CLI** (`tofu`) installed and available in your system’s `PATH`.
  → See installation instructions at: [https://opentofu.org/docs/intro/install/](https://opentofu.org/docs/intro/install/)
- Proper **cloud provider credentials** configured (e.g., AWS keys, DigitalOcean tokens, etc.)
  → Follow our guide: [`docs/clouds-credentials.md`](../docs/clouds-credentials.md)

---

## Environment Variables

- `ALGO_DEBUG=1`
  Enable debug output to see detailed logs during script execution, helpful for troubleshooting.

- `TF_VAR_state_passphrase`
  Optionally provide your Terraform/OpenTofu state encryption passphrase through this environment variable to avoid interactive prompts.

---

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
