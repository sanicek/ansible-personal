#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Prefer repo-local tooling
if [ -d "${ROOT_DIR}/.venv/bin" ]; then
  export PATH="${ROOT_DIR}/.venv/bin:$PATH"
fi

export ANSIBLE_COLLECTIONS_PATH="${ROOT_DIR}/.ansible/collections:${ROOT_DIR}"

preflight() {
  local missing=()
  for cmd in ansible-galaxy ansible-playbook molecule podman; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    printf 'ERROR: Missing required commands: %s\n' "${missing[*]}" >&2
    printf '\nOne-time setup (required before first validation):\n' >&2
    printf '  1. python -m venv .venv\n' >&2
    printf '     .venv/bin/python -m pip install -r requirements-dev.txt\n' >&2
    printf '  2. .venv/bin/ansible-galaxy collection install -r requirements.yml -p .ansible/collections\n' >&2
    printf '  3. .venv/bin/ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_molecule.yml\n' >&2
    exit 1
  fi
}

install_dependencies() {
  ansible-galaxy collection install -r requirements.yml -p "${ROOT_DIR}/.ansible/collections"
}

syntax_check_playbooks() {
  local playbook

  for playbook in "$@"; do
    ansible-playbook "$playbook" --syntax-check
  done
}

build_personal_collection() {
  ansible-galaxy collection build ansible_collections/sanicek/personal --force
}

build_all_collections() {
  build_personal_collection
  ansible-galaxy collection build ansible_collections/sanicek/server --force
}

run_molecule_scenarios() {
  local scenario

  for scenario in "$@"; do
    molecule test -s "$scenario"
  done
}

validate_arch_shell() {
  preflight
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_shell.yml
  build_personal_collection
  run_molecule_scenarios arch_shell
}

validate_arch_terminal() {
  preflight
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_terminal.yml
  build_personal_collection
  run_molecule_scenarios arch_terminal
}

validate_arch_cloud() {
  preflight
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
  build_personal_collection
  run_molecule_scenarios arch_cloud
}

validate_arch_k8s() {
  preflight
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_k8s.yml
  build_personal_collection
  run_molecule_scenarios arch_k8s
}

validate_arch_opencode() {
  preflight
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_opencode.yml
  build_personal_collection
  run_molecule_scenarios arch_opencode
}

validate_arch_rimworld_modding() {
  preflight
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_rimworld_modding.yml
  build_personal_collection
  run_molecule_scenarios arch_rimworld_modding
}

validate_arch_godot() {
  preflight
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_godot.yml
  build_personal_collection
  run_molecule_scenarios arch_godot
}

validate_full() {
  local playbooks=(
    ansible_collections/sanicek/personal/playbooks/fedora_workstation.yml
    ansible_collections/sanicek/personal/playbooks/fedora_shell.yml
    ansible_collections/sanicek/personal/playbooks/fedora_gui_apps.yml
    ansible_collections/sanicek/personal/playbooks/fedora_terminal.yml
    ansible_collections/sanicek/personal/playbooks/fedora_molecule.yml
    ansible_collections/sanicek/personal/playbooks/arch_gui_apps.yml
    ansible_collections/sanicek/personal/playbooks/arch_opencode.yml
    ansible_collections/sanicek/personal/playbooks/arch_terminal.yml
    ansible_collections/sanicek/personal/playbooks/arch_shell.yml
    ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
    ansible_collections/sanicek/personal/playbooks/arch_k8s.yml
    ansible_collections/sanicek/personal/playbooks/arch_rimworld_modding.yml
    ansible_collections/sanicek/personal/playbooks/arch_godot.yml
    ansible_collections/sanicek/personal/playbooks/arch_molecule.yml
    ansible_collections/sanicek/server/playbooks/arch_ollama.yml
    ansible_collections/sanicek/server/playbooks/arch_sshd.yml
  )

  preflight
  install_dependencies
  syntax_check_playbooks "${playbooks[@]}"
  build_all_collections
  run_molecule_scenarios arch_shell arch_terminal arch_cloud arch_k8s arch_opencode arch_rimworld_modding arch_godot
}

usage() {
  printf 'Usage: %s [full|arch_shell|arch_terminal|arch_cloud|arch_k8s|arch_opencode|arch_rimworld_modding|arch_godot]\n' "${0##*/}" >&2
}

target="${1:-full}"

case "$target" in
  full)
    validate_full
    ;;
  arch_shell)
    validate_arch_shell
    ;;
  arch_terminal)
    validate_arch_terminal
    ;;
  arch_cloud)
    validate_arch_cloud
    ;;
  arch_k8s)
    validate_arch_k8s
    ;;
  arch_opencode)
    validate_arch_opencode
    ;;
  arch_rimworld_modding)
    validate_arch_rimworld_modding
    ;;
  arch_godot)
    validate_arch_godot
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac
