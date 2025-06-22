# Workspaces

The `./algo` wrapper lets you manage your VPN installations using workspaces. By default, it uses the `default` workspace unless you select or create another one during setup.

## What are workspaces?

Workspaces allow you to manage multiple, isolated VPN installations — either in the same cloud provider or across different providers — all from the same codebase.

Each workspace:

- Has its own independent state file, which tracks the resources created within that workspace.
- Maintains separate cloud resources, including keys, certificates, and server instances.
- Can have different users and settings specific to that deployment.
- Can use a custom configuration file with the `--config-file` flag (defaults to `config.yaml`).

This is ideal if you want to:

- Host VPNs for different groups of users (e.g. family, team, friends)
- Deploy VPNs to different providers for testing or redundancy
- Keep production and test environments completely isolated

## Example usage

```bash
./algo --provider Lightsail --workspace my-team-vpn
```

This creates or selects the my-team-vpn workspace and provisions everything independently from other installations.
