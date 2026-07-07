# sanicek.personal

Personal configuration-as-code Ansible collection.

The current content targets Fedora and Arch Linux. Platform support is organized through separate platform-specific roles instead of compatibility branches inside roles.

## Playbooks

Run from the repository root.

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_gui_apps.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/debug_facts.yml
```

## Platform Coverage

Fedora currently has workstation, shell, GUI application, and terminal playbooks.

Arch Linux currently has shell environment and cloud CLI setup.

## Build

```bash
ansible-galaxy collection build ansible_collections/sanicek/personal --force
```
