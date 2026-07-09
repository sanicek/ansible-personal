# AGENTS.md

## Repo Shape
- This is a local Ansible collection workspace, not a packaged app. Collections live under `ansible_collections/sanicek/personal` and `ansible_collections/sanicek/server`.
- Run Ansible commands from the repo root so `ansible.cfg` applies `inventory = ./inventories/local/hosts` and `collections_path = .`.
- The only inventory target is local: `localhost ansible_connection=local` in `inventories/local/hosts`.

## Variables And Secrets
- Shared committed defaults belong in `inventories/local/group_vars/all.yml`.
- Private machine overrides belong in gitignored `inventories/local/host_vars/localhost.yml`; start from `inventories/local/host_vars/localhost.yml.example`.
- Do not commit generated collection archives (`*.tar.gz`) or `inventories/local/host_vars/localhost.yml`; both are gitignored.

## Role Conventions
- Platform support is split by role/playbook name (`arch_*`, `fedora_*`); do not add cross-platform branching inside an existing platform-specific role unless necessary.
- Bootstrap roles set `user_name`, `user_home`, and `package_manager` from the caller's environment. User-scoped tasks depend on those facts, so keep bootstrap before dependent roles in playbooks.
- Arch roles use `community.general.pacman`; Fedora roles use `ansible.builtin.dnf`. Both collections declare `community.general >=8.0.0` and require Ansible `>=2.16.0`.
- Arch support currently accepts `Archlinux` and `CachyOS`; Fedora bootstrap asserts exactly `Fedora`.
- Server roles manage their own firewall via `sanicek.server.ufw`; `arch_ollama` only opens UFW when `arch_ollama_host` is not localhost-only.

## Commands
- Fresh Arch bootstrap only: `sudo bash scripts/bootstrap.sh [username]` (`username` defaults to `cac`; installs `sudo`, `git`, `ansible`, creates the user, and enables passwordless sudo).
- Run one playbook: `ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml`.
- Focused syntax check: `ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml --syntax-check`.
- Build collections after metadata or role changes: `ansible-galaxy collection build ansible_collections/sanicek/personal --force` and `ansible-galaxy collection build ansible_collections/sanicek/server --force`.
- There is no repo-local CI, Makefile, pre-commit, ansible-lint, Molecule, or test harness currently; use relevant playbook syntax checks plus collection build as verification.

## Playbook Map
- Fedora workstation: `fedora_bootstrap`, common packages, power, GUI apps, kitty, fonts, bash-git-prompt, shell, fzf.
- Fedora focused playbooks: `fedora_shell.yml`, `fedora_gui_apps.yml`, `fedora_terminal.yml`.
- Arch focused playbooks: `arch_gui_apps.yml`, `arch_opencode.yml`, `arch_terminal.yml`, `arch_shell.yml`, `arch_cloud.yml`, `arch_k8s.yml`.
- Server playbooks: `arch_ollama.yml` and `arch_sshd.yml` in `ansible_collections/sanicek/server/playbooks`.
