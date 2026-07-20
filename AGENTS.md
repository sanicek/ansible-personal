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

## Agent Routing

- The orchestrator selects the validation scope and dispatches command-only validation to `@validator` as a background subagent.
- **Delegate to @validator when:** running `scripts/validate.sh` (full or focused targets), direct `molecule test` runs, Ansible syntax checks, or collection builds.
- **Do not delegate to @validator when:** implementing or editing source/tests, selecting the validation scope, performing architecture or code review, or running documentation-only quick checks.
- The validator inherits the active profile/model. Editing tools and nested delegation are denied; it may create the gitignored `.venv` and run validation commands. It is instructed not to modify source, commit, or push.

## Git Workflow (Build Mode)

- `main` is protected and must never receive direct commits or pushes. All changes go through feature branches.
- When making changes in build mode:
  1. Create a branch from `main` with a conventional prefix: `feat/`, `fix/`, `chore/`, `refactor/`, or `docs/` followed by a short kebab-case description (e.g. `feat/add-arch-gaming`).
  2. Make the changes.
  3. Run the appropriate validation: full `scripts/validate.sh` for broad changes, or the focused variant (e.g. `scripts/validate.sh arch_shell`) for single-role changes. For docs-only changes that don't touch Ansible content, a syntax-only check on affected playbooks is acceptable.
  4. After validation passes, stage the changed files and commit with a [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) message (`feat(scope): description`, `fix: description`, `chore: description`, `docs: description`, etc.).
  5. Push the branch with `git push -u origin <branch-name>`.
  6. Create a pull request with `gh pr create --title "..." --body "..."`. The body must include a summary of what changed and which validation was run.
- After creating the PR, ask the user for confirmation ("Ready to merge, or need additional changes?").
  - If the user requests changes, reuse the existing feature branch (do not create a new one). Make the changes, validate, commit, and push; the PR updates automatically, then ask again.
  - If the user confirms merge, merge the PR with `gh pr merge --merge --delete-branch`, then clean up locally: `git checkout main`, `git pull origin main`, `git branch -d <branch-name>`, and `git remote prune origin`.
- This workflow applies to every change, including updates to `AGENTS.md` itself.

## Commands
- Fresh Arch bootstrap only: `sudo bash scripts/bootstrap.sh [username]` (`username` defaults to `cac`; installs `sudo`, `git`, `ansible`, creates the user, and enables passwordless sudo).
- Run one playbook: `ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml`.
- Focused syntax check: `ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_shell.yml --syntax-check`.
- All validation targets require Molecule and Podman. One-time setup (run once per host):
  - Python tooling: `python -m venv .venv` then `.venv/bin/python -m pip install -r requirements-dev.txt` (provides `ansible-galaxy`, `ansible-playbook`, `molecule`).
  - External collections: `.venv/bin/ansible-galaxy collection install -r requirements.yml -p .ansible/collections`
  - Podman host setup: `.venv/bin/ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_molecule.yml`; use `fedora_molecule.yml` only for explicit Fedora maintenance work.
  - `scripts/validate.sh` auto-prefers `.venv/bin` on `PATH`; manual activation with `. .venv/bin/activate` is optional.
- Full validation entrypoint: `scripts/validate.sh` (or `scripts/validate.sh full`); it runs a preflight check, installs external collections into gitignored `.ansible/collections`, runs syntax checks, builds both collections, and runs `molecule test -s arch_shell`, `molecule test -s arch_terminal`, `molecule test -s arch_cloud`, `molecule test -s arch_k8s`, `molecule test -s arch_opencode`, `molecule test -s arch_rimworld_modding`, `molecule test -s arch_godot`, and `molecule test -s arch_gz302ea_audio`.
- Focused validation targets: `scripts/validate.sh arch_shell`, `scripts/validate.sh arch_terminal`, `scripts/validate.sh arch_cloud`, `scripts/validate.sh arch_k8s`, `scripts/validate.sh arch_opencode`, `scripts/validate.sh arch_rimworld_modding`, `scripts/validate.sh arch_godot`, and `scripts/validate.sh arch_gz302ea_audio`; use these when changes are limited to one role family.
- Molecule may emit non-fatal warnings about missing `molecule/default/molecule.yml` and missing role `requirements.yml`; these are expected with this repo's explicit scenarios and collection-only dependency setup. Do not mention them in user-facing validation summaries when `scripts/validate.sh`, `molecule test -s arch_shell`, `molecule test -s arch_terminal`, `molecule test -s arch_cloud`, `molecule test -s arch_k8s`, `molecule test -s arch_opencode`, `molecule test -s arch_rimworld_modding`, `molecule test -s arch_godot`, or `molecule test -s arch_gz302ea_audio` exits successfully.
- Build collections after metadata or role changes: `ansible-galaxy collection build ansible_collections/sanicek/personal --force` and `ansible-galaxy collection build ansible_collections/sanicek/server --force`.
- There is no repo-local CI, Makefile, pre-commit, or ansible-lint currently; use relevant playbook syntax checks, collection build, and available Molecule scenarios as verification.

## Playbook Map
- Fedora workstation: `fedora_bootstrap`, common packages, power, GUI apps, kitty, fonts, bash-git-prompt, shell, fzf.
- Fedora focused playbooks: `fedora_shell.yml`, `fedora_gui_apps.yml`, `fedora_terminal.yml`.
- Arch focused playbooks: `arch_gui_apps.yml`, `arch_opencode.yml`, `arch_terminal.yml`, `arch_shell.yml`, `arch_cloud.yml`, `arch_k8s.yml`, `arch_rimworld_modding.yml`, `arch_godot.yml`, `arch_gz302ea_audio.yml`.
- Server playbooks: `arch_ollama.yml` and `arch_sshd.yml` in `ansible_collections/sanicek/server/playbooks`.
