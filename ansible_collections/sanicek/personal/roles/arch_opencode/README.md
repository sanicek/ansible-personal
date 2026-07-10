# arch_opencode

Installs opencode from native Arch Linux packages.

Optionally configures a global opencode Ollama provider in `~/.config/opencode/opencode.jsonc`. Existing JSON-compatible config is preserved and merged; comments in that file are not supported by this role's merge step.

Set `arch_opencode_ollama_context_length` to add a `limit.context` value to each managed Ollama model. Set `arch_opencode_ollama_output_limit` to control the paired `limit.output` value, which defaults to `8192`.

Keep `arch_opencode_ollama_context_length` aligned with the Ollama service's `arch_ollama_context_length` unless intentionally testing a lower opencode-side limit.

The role can also apply an opencode profile with `arch_opencode_profile`. Profiles are stored under `vars/profiles/` and may install Bun, register opencode plugins, configure TUI plugins, set shell environment exports, and write plugin-specific config files.

`arch_opencode_profile=cloud_openai` installs Bun for npm plugin support, registers `oh-my-opencode-slim@latest`, enables background subagents, disables the built-in `explore` and `general` agents, enables LSP when it is not already configured, and writes an OpenAI preset intended for ChatGPT Plus. It uses GPT-5.6 Sol for orchestration and architecture, GPT-5.5 Fast for research and exploration, and GPT-5.5 Medium for design and implementation.

`arch_opencode_profile=hybrid_qwen_go` keeps the same plugin, TUI, background-subagent, disabled-agent, and LSP behavior, but writes two runtime-selectable `oh-my-opencode-slim` presets. The active default remains `openai`, copied from `cloud_openai`; switch to `hybrid` in `~/.config/opencode/oh-my-opencode-slim.json` when you want OpenAI orchestration/oracle, local Ollama exploration, and opencode-go DeepSeek librarian/fixer/designer agents to coexist in one deployment. This profile also configures the opencode Ollama provider for exactly `qwen3.5:9b` as `Qwen3.5 9B (local Ollama)` with attachment, reasoning, tool-call, `limit.context=131072`, and `limit.output=8192`, replacing any existing Ollama provider model entries in opencode config.

Run a profile with:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=cloud_openai
# or
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=hybrid_qwen_go
```

After applying either profile, authenticate interactively with `opencode auth login`, select ChatGPT Plus/Pro, and refresh the subscription model list with `opencode models --refresh`. For `hybrid_qwen_go`, also install/start Ollama separately and pull the exact local model with `ollama pull qwen3.5:9b`; opencode-go provider authentication must be configured outside this role before selecting the `hybrid` preset.
