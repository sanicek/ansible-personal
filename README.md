# ansible-personal

Personal configuration-as-code using Ansible.

This repository is organized as local Ansible collections:

```text
ansible_collections/sanicek/personal
ansible_collections/sanicek/server
```

Current content targets Arch Linux and Fedora. Arch Linux is the active target platform for new features, validation, and role improvements. Fedora content is kept for basic maintenance only; avoid adding new Fedora playbooks, Molecule scenarios, or improvement work unless explicitly requested.

## Bootstrap

For a fresh Arch Linux host, run the minimal bootstrap script first:

```bash
sudo bash scripts/bootstrap.sh [username]
```

The username defaults to `cac`. The script installs `sudo`, `git`, and `ansible`, creates the user, adds it to `wheel`, and configures passwordless sudo for follow-up Ansible runs.

## Local Variables

This repository targets localhost. Shared committed defaults live in:

```text
inventories/local/group_vars/all.yml
```

Private local overrides should live in a gitignored host vars file:

```bash
cp inventories/local/host_vars/localhost.yml.example \
  inventories/local/host_vars/localhost.yml
```

`host_vars/localhost.yml` overrides `group_vars/all.yml`, making it the local equivalent of a private tfvars file.

## Usage

Run playbooks from the repository root:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_gui_apps.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_gui_apps.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_terminal.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_k8s.yml
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_ollama.yml
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_sshd.yml
```

## Validation

Install Podman and local Python tooling prerequisites with the Arch Molecule setup playbook:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_molecule.yml
```

For explicit Fedora maintenance work only, use `ansible_collections/sanicek/personal/playbooks/fedora_molecule.yml`.

Install Molecule into a repository-local virtual environment:

```bash
python -m venv .venv
. .venv/bin/activate
pip install -r requirements-dev.txt
```

Run the full validation entrypoint from the repository root:

```bash
scripts/validate.sh
```

The validation script installs external Ansible collections into gitignored `.ansible/collections`, runs playbook syntax checks, builds local collections, and runs Podman-backed Molecule scenarios with idempotence checks. Without arguments it runs full validation.

Focused targets are available when changing one playbook or role family:

```bash
scripts/validate.sh arch_shell
scripts/validate.sh arch_terminal
scripts/validate.sh arch_cloud
scripts/validate.sh arch_k8s
scripts/validate.sh arch_opencode
scripts/validate.sh full
```

Focused validation commands are still useful while developing:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_gui_apps.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_terminal.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_cloud.yml --syntax-check
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_k8s.yml --syntax-check
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_ollama.yml --syntax-check
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_sshd.yml --syntax-check
ansible-galaxy collection build ansible_collections/sanicek/personal --force
ansible-galaxy collection build ansible_collections/sanicek/server --force
molecule test -s arch_shell
molecule test -s arch_terminal
molecule test -s arch_cloud
molecule test -s arch_k8s
molecule test -s arch_opencode
```
