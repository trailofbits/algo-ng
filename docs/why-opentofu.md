# Why OpenTofu?

In short, OpenTofu/Terraform makes managing cloud infrastructure easier, faster, and more reliable.

If you still prefer to use our old Ansible codebase, it’s available in the `ansible` folder — but please note this will be deprecated and removed later this year.

## The Ansible struggle

- Managing Ansible has become a real pain. Its heavy Python dependencies are a headache to install and keep up-to-date.
- Ansible wasn’t really built for provisioning cloud infrastructure — it’s more about configuring servers once they’re running.
- Playbooks can behave differently depending on the environment, which leads to unpredictable results.

## Why we switched to OpenTofu

- Upgrades are more predictable and stable, which means fewer surprises and less firefighting.
- It has way fewer dependencies to manage, making it simpler to set up and maintain.
- Managing modules is easier and more consistent.
- Terraform is built specifically for cloud infrastructure — it knows how to create, update, and destroy resources cleanly.
- It’s much faster — about 20 times quicker at spinning up resources compared to Ansible.
- Multiple environments are a breeze to handle with workspaces, no more messy duplications.
- When you rebuild servers, Terraform keeps important things like IP addresses and private keys unchanged. So your VPN stays up and running, making upgrades seamless.
- Unlike vanilla Terraform, OpenTofu offers better support for encrypting and protecting your local state file. While Terraform Cloud (HCP) provides encryption, our current way of supplying client configs doesn’t fit well with HCP, so OpenTofu was a better fit for us.
