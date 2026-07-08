# sanicek.server

Server configuration-as-code Ansible collection.

## Playbooks

Run from the repository root.

```bash
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_ollama.yml
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_sshd.yml
```

## Local Variables

This collection uses the repository-level `inventories/local` inventory. Private localhost overrides should be copied from `inventories/local/host_vars/localhost.yml.example` to the gitignored `inventories/local/host_vars/localhost.yml`.

Service roles own their own firewall exposure. For example, `arch_ollama` opens its API port only when `arch_ollama_host` is not localhost-only.

## Build

```bash
ansible-galaxy collection build ansible_collections/sanicek/server --force
```
