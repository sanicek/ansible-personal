# ansible-personal

Personal configuration-as-code using Ansible.

This repository is organized as a local Ansible collection:

```text
ansible_collections/sanicek/personal
```

Current content targets Fedora and Arch Linux. Platform support is organized through separate platform-specific roles.

## Usage

Run playbooks from the repository root:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_gui_apps.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_k8s.yml
```

## Validation

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_k8s.yml --syntax-check
ansible-galaxy collection build ansible_collections/sanicek/personal --force
```
