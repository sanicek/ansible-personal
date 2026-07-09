#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export ANSIBLE_COLLECTIONS_PATH="${ROOT_DIR}/.ansible/collections:${ROOT_DIR}"

install_dependencies() {
  ansible-galaxy collection install -r requirements.yml -p "${ROOT_DIR}/.ansible/collections"
}

require_molecule() {
  if ! command -v molecule >/dev/null 2>&1; then
    printf 'molecule is not installed. Create a virtualenv and run: pip install -r requirements-dev.txt\n' >&2
    exit 1
  fi
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

  require_molecule
  for scenario in "$@"; do
    molecule test -s "$scenario"
  done
}

validate_arch_shell() {
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_shell.yml
  build_personal_collection
  run_molecule_scenarios arch_shell
}

validate_arch_terminal() {
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_terminal.yml
  build_personal_collection
  run_molecule_scenarios arch_terminal
}

validate_arch_cloud() {
  install_dependencies
  syntax_check_playbooks ansible_collections/sanicek/personal/playbooks/arch_cloud.yml
  build_personal_collection
  run_molecule_scenarios arch_cloud
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
    ansible_collections/sanicek/personal/playbooks/arch_molecule.yml
    ansible_collections/sanicek/server/playbooks/arch_ollama.yml
    ansible_collections/sanicek/server/playbooks/arch_sshd.yml
  )

  install_dependencies
  syntax_check_playbooks "${playbooks[@]}"
  build_all_collections
  run_molecule_scenarios arch_shell arch_terminal arch_cloud
}

usage() {
  printf 'Usage: %s [full|arch_shell|arch_terminal|arch_cloud]\n' "${0##*/}" >&2
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
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac
