#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export ANSIBLE_COLLECTIONS_PATH="${ROOT_DIR}/.ansible/collections:${ROOT_DIR}"

ansible-galaxy collection install -r requirements.yml -p "${ROOT_DIR}/.ansible/collections"

playbooks=(
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

for playbook in "${playbooks[@]}"; do
  ansible-playbook "$playbook" --syntax-check
done

ansible-galaxy collection build ansible_collections/sanicek/personal --force
ansible-galaxy collection build ansible_collections/sanicek/server --force

if ! command -v molecule >/dev/null 2>&1; then
  printf 'molecule is not installed. Create a virtualenv and run: pip install -r requirements-dev.txt\n' >&2
  exit 1
fi

molecule test -s arch_shell
molecule test -s fedora_shell
