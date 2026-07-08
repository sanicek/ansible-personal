# sanicek.personal

Personal configuration-as-code Ansible collection.

The current content targets Fedora and Arch Linux. Platform support is organized through separate platform-specific roles instead of compatibility branches inside roles.

## Bootstrap

For first-run Arch Linux setup, use the repository-level `scripts/bootstrap.sh` script before running collection playbooks. It installs the minimal baseline needed for follow-up local Ansible runs.

## Local Variables

Committed local defaults live in the repository-level `inventories/local/group_vars/all.yml`. Private localhost overrides should be copied from `inventories/local/host_vars/localhost.yml.example` to the gitignored `inventories/local/host_vars/localhost.yml`.

## Playbooks

Run from the repository root.

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_gui_apps.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_gui_apps.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_k8s.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/debug_facts.yml
```

## Platform Coverage

Fedora currently has workstation, shell, GUI application, and terminal playbooks.

Arch Linux currently has GUI application, terminal, shell environment, cloud CLI, and Kubernetes CLI setup.

The Arch GUI application playbook uses AUR for Google Chrome and Visual Studio Code because their official proprietary builds are needed for cloud sync. KeePassXC is installed from native Arch Linux packages.

## Build

```bash
ansible-galaxy collection build ansible_collections/sanicek/personal --force
```
