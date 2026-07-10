# arch_opencode

Installs opencode from native Arch Linux packages.

Optionally configures a global opencode Ollama provider in `~/.config/opencode/opencode.jsonc`. Existing JSON-compatible config is preserved and merged; comments in that file are not supported by this role's merge step.

Set `arch_opencode_ollama_context_length` to add a `limit.context` value to each managed Ollama model. Set `arch_opencode_ollama_output_limit` to control the paired `limit.output` value, which defaults to `8192`.

Keep `arch_opencode_ollama_context_length` aligned with the Ollama service's `arch_ollama_context_length` unless intentionally testing a lower opencode-side limit.

The role can also apply an opencode profile with `arch_opencode_profile`. Profiles are stored under `vars/profiles/` and may install Bun, register opencode plugins, configure TUI plugins, set shell environment exports, and write plugin-specific config files. For example, `arch_opencode_profile=cloud_openai` installs Bun for npm plugin support, registers `oh-my-opencode-slim@latest`, enables background subagents, disables the built-in `explore` and `general` agents, enables LSP when it is not already configured, and writes a light OpenAI `oh-my-opencode-slim` profile.

Run a profile with:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=cloud_openai
```
