# arch_opencode

Installs opencode from native Arch Linux packages.

## Profiles

The role can optionally deploy a static profile to `~/.config/opencode/` by setting `arch_opencode_profile`. Profiles are exact configuration files stored in the role; deployment overwrites the managed files completely. Unknown or sibling files in `~/.config/opencode/` (e.g., state, auth, or manually-created files) are never touched.

Valid profile values:

- `""` (empty / default): Install opencode only. Existing config files in `~/.config/opencode/` are left untouched.
- `cloud_openai`: OpenAI-only deployment via ChatGPT Plus/Pro.
- `hybrid_qwen_go`: Multi-provider deployment combining OpenAI orchestration, local Ollama exploration, and opencode-go DeepSeek agents.

An invalid profile name fails early with a message listing the valid values.

### Managed files

Each profile deploys exactly three files:

| File | Purpose |
|------|---------|
| `opencode.jsonc` | Core opencode configuration |
| `tui.jsonc` | OpenCode terminal UI configuration (OmO plugin registered for TUI extensions) |
| `oh-my-opencode-slim.json` | Oh-My-OpenCode-Slim plugin configuration |

All managed files are replaced in full on every run. Switching profiles or re-running the same profile eliminates any keys from previous or hand-edited versions because the entire file is overwritten.

### cloud_openai profile

Installs Bun, deploys `oh-my-opencode-slim@latest` as both a core plugin and TUI plugin, enables background subagents, disables the built-in `explore` and `general` agents, enables LSP, and writes an OpenAI-only OmO preset intended for ChatGPT Plus/Pro.

OmO agents:
- Orchestrator: `openai/gpt-5.6-sol` (medium)
- Oracle: `openai/gpt-5.6-sol` (high)
- Librarian: `openai/gpt-5.5` (fast) — MCPs: websearch, context7, gh_grep
- Explorer: `openai/gpt-5.5` (fast)
- Designer: `openai/gpt-5.5` (medium)
- Fixer: `openai/gpt-5.5` (medium)

### hybrid_qwen_go profile

Same plugin and background-subagent setup as `cloud_openai`, plus an opencode Ollama provider configuration for `qwen3.5:9b` with attachment, reasoning, tool-call, 131072 context limit, and 8192 output limit. Deploys two OmO presets: `openai` (identical to `cloud_openai`) and `hybrid`.

Hybrid OmO agents:
- Orchestrator: `openai/gpt-5.6-sol` (medium)
- Oracle: `openai/gpt-5.6-sol` (high)
- Librarian: `opencode-go/deepseek-v4-flash` — MCPs: websearch, context7, gh_grep
- Explorer: `ollama/qwen3.5:9b`
- Designer: `opencode-go/deepseek-v4-pro` (max)
- Fixer: `opencode-go/deepseek-v4-pro` (max)

Switch between presets by changing `"preset"` in `oh-my-opencode-slim.json`.

### Auto-update and versioning

`oh-my-opencode-slim@latest` is pinned as `@latest` in plugin references, and OmO `autoUpdate` is enabled. The role does not pin or disable updates — the plugin fetches the latest compatible version at runtime.

### Authentication and secrets

This role does not manage API keys, login credentials, or provider authentication. After applying a profile, authenticate interactively:
- `opencode auth login` for ChatGPT Plus/Pro
- `opencode models --refresh` to update the subscription model list
- For `hybrid_qwen_go` with the `hybrid` preset: configure opencode-go authentication outside this role, and install/start Ollama separately (`ollama pull qwen3.5:9b`)

## Usage

Install opencode only (no config changes):
```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml
```

Apply a profile:
```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=cloud_openai
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=hybrid_qwen_go
```

## Overwrite semantics

The role only writes the three managed files listed above. It never removes files from `~/.config/opencode/`. Switching profiles replaces managed files with the new profile's versions; switching back to no profile (`arch_opencode_profile=""`) leaves the previously-deployed managed files in place.

Shell environment configuration (e.g., `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS`) is only written to `.bashrc` when a profile is selected. Install-only runs do not touch `.bashrc` or any config files.

Re-running the same profile is safe and idempotent (the same file content is deployed each time).
