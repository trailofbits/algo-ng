# Algo-NG Documentation

Welcome to the documentation for **Algo-NG** — the next-generation, Terraform-based version of the Algo VPN installer. This section covers everything you need to understand how the system works, how to deploy it, and why certain choices were made.

## Table of Contents

### Architecture & Design Choices

- [Why OpenTofu](./why-opentofu.md)
  Learn why we switched from Ansible to Terraform, and why we specifically chose OpenTofu for Algo-NG.

- [Why Not Cloud-Init](./cloud-init.md)
  An explanation of why we chose `remote-exec` over `cloud-init`, including compatibility and flexibility reasons.

### Setup & Usage

- [Algo Wrapper](./algo-wrapper.md)
  Learn how to use the `./algo` Python wrapper to configure and deploy your VPN with OpenTofu, select workspaces, pass configuration flags, and manage environments.

- [State Passphrase](./state-passphrase.md)
  Understand how the state file is protected using a passphrase, and how to manage it securely with environment variables.

- [Workspaces](./workspaces.md)
  How to use OpenTofu workspaces to manage multiple independent VPN deployments with separate configuration and state.
