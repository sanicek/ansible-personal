# ansible-personal

Personal configuration-as-code using Ansible.

This repository is organized as a local Ansible collection:

```text
ansible_collections/sanicek/personal
```

Current content targets Fedora and Arch Linux. Platform support is organized through separate platform-specific roles.

## Bootstrap

For a fresh Arch Linux host, run the minimal bootstrap script first:

```bash
sudo bash scripts/bootstrap.sh [username]
```

The username defaults to `cac`. The script installs `sudo`, `git`, and `ansible`, creates the user, adds it to `wheel`, and configures passwordless sudo for follow-up Ansible runs.

## Local Variables

This repository targets localhost. Shared committed defaults live in:

```text
ansible_collections/sanicek/personal/inventories/local/group_vars/all.yml
```

Private local overrides should live in a gitignored host vars file:

```bash
cp ansible_collections/sanicek/personal/inventories/local/host_vars/localhost.yml.example \
  ansible_collections/sanicek/personal/inventories/local/host_vars/localhost.yml
```

`host_vars/localhost.yml` overrides `group_vars/all.yml`, making it the local equivalent of a private tfvars file.

## Usage

Run playbooks from the repository root:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_gui_apps.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_k8s.yml
```

## Validation

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_terminal.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_k8s.yml --syntax-check
ansible-galaxy collection build ansible_collections/sanicek/personal --force
```
