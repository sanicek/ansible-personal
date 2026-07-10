# AGENTS.md

## Repo Shape
- This is a local Ansible collection workspace, not a packaged app. Collections live under `ansible_collections/sanicek/personal` and `ansible_collections/sanicek/server`.
- Run Ansible commands from the repo root so `ansible.cfg` applies `inventory = ./inventories/local/hosts` and `collections_path = ./.ansible/collections:.`.
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
- Arch is the active target platform for new features, validation, and role improvements. Fedora is sunset/maintenance-only: keep existing playbooks basically functional, but do not add new Fedora playbooks, Molecule scenarios, roles, or improvement work unless explicitly requested.
- Server roles manage their own firewall via `sanicek.server.ufw`; `arch_ollama` only opens UFW when `arch_ollama_host` is not localhost-only.

## Git Workflow (Build Mode)

- `main` is protected and must never receive direct commits or pushes. All changes go through feature branches.
- When making changes in build mode:
  1. Create a branch from `main` with a conventional prefix: `feat/`, `fix/`, `chore/`, `refactor/`, or `docs/` followed by a short kebab-case description (e.g. `feat/add-arch-gaming`).
  2. Make the changes.
  3. Run the appropriate validation: full `scripts/validate.sh` for broad changes, or the focused variant (e.g. `scripts/validate.sh arch_shell`) for single-role changes. For docs-only changes that don't touch Ansible content, a syntax-only check on affected playbooks is acceptable.
  4. After validation passes, stage the changed files and commit with a [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) message (`feat(scope): description`, `fix: description`, `chore: description`, `docs: description`, etc.).
  5. Push the branch with `git push -u origin <branch-name>`.
  6. Create a pull request with `gh pr create --title "..." --body "..."`. The body must include a summary of what changed and which validation was run.
- Do not merge the PR. Leave it for the user to review and merge manually.
- When additional changes are needed on an open PR, reuse the existing feature branch (do not create a new branch). Commit and push to the same branch; the PR updates automatically.
- This workflow applies to every change, including updates to `AGENTS.md` itself.

## Commands
- Fresh Arch bootstrap only: `sudo bash scripts/bootstrap.sh [username]` (`username` defaults to `cac`; installs `sudo`, `git`, `ansible`, creates the user, and enables passwordless sudo).
- Run one playbook: `ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml`.
- Focused syntax check: `ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml --syntax-check`.
- Install Podman-backed Molecule prerequisites for active validation with `ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_molecule.yml`; use `fedora_molecule.yml` only for explicit Fedora maintenance work.
- Install Python validation tooling in a local virtualenv: `python -m venv .venv`, `. .venv/bin/activate`, then `pip install -r requirements-dev.txt`.
- Full validation entrypoint: `scripts/validate.sh`; it installs external collections into gitignored `.ansible/collections`, runs syntax checks, builds both collections, and runs `molecule test -s arch_shell`, `molecule test -s arch_terminal`, `molecule test -s arch_cloud`, `molecule test -s arch_k8s`, and `molecule test -s arch_opencode`.
- Focused validation targets: `scripts/validate.sh arch_shell`, `scripts/validate.sh arch_terminal`, `scripts/validate.sh arch_cloud`, `scripts/validate.sh arch_k8s`, and `scripts/validate.sh arch_opencode`; use these when changes are limited to one role family.
- Molecule may emit non-fatal warnings about missing `molecule/default/molecule.yml` and missing role `requirements.yml`; these are expected with this repo's explicit scenarios and collection-only dependency setup. Do not mention them in user-facing validation summaries when `scripts/validate.sh`, `molecule test -s arch_shell`, `molecule test -s arch_terminal`, `molecule test -s arch_cloud`, `molecule test -s arch_k8s`, or `molecule test -s arch_opencode` exits successfully.
- Build collections after metadata or role changes: `ansible-galaxy collection build ansible_collections/sanicek/personal --force` and `ansible-galaxy collection build ansible_collections/sanicek/server --force`.
- There is no repo-local CI, Makefile, pre-commit, or ansible-lint currently; use relevant playbook syntax checks, collection build, and available Molecule scenarios as verification.

## Playbook Map
- Fedora workstation: `fedora_bootstrap`, common packages, power, GUI apps, kitty, fonts, bash-git-prompt, shell, fzf.
- Fedora focused playbooks: `fedora_shell.yml`, `fedora_gui_apps.yml`, `fedora_terminal.yml`.
- Arch focused playbooks: `arch_gui_apps.yml`, `arch_opencode.yml`, `arch_terminal.yml`, `arch_shell.yml`, `arch_cloud.yml`, `arch_k8s.yml`.
- Server playbooks: `arch_ollama.yml` and `arch_sshd.yml` in `ansible_collections/sanicek/server/playbooks`.
