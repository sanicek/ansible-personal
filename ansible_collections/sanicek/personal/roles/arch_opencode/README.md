# arch_opencode

Installs the latest stable `opencode-ai` npm release with Bun on Arch Linux.

## Installation and upgrades

Bun is installed from Pacman on every role run. The role removes the legacy Pacman `opencode` package, resolves the npm registry's `latest` version for `opencode-ai`, and installs that explicit version globally for the target user only when the user's installed version differs or is missing. The user-global binary is `~/.bun/bin/opencode` and is exposed through a role-managed `/usr/local/bin/opencode` symlink.

Only upstream Linux `x86_64`/`amd64` and `aarch64`/`arm64` architectures are supported. Re-running the role checks npm metadata and upgrades OpenCode when a newer stable release is available.

## Profiles

The role can optionally deploy a static profile to `~/.config/opencode/` by setting `arch_opencode_profile`. Profiles are exact configuration files stored in the role; deployment overwrites the managed files completely. Unknown or sibling files in `~/.config/opencode/` (e.g., state or manually-created files) are never touched.

Valid profile values:

- `""` (empty / default): Install OpenCode only. Existing config files in `~/.config/opencode/` are left untouched.
- `omo-slim-cloud-openai`: OpenAI-only deployment via ChatGPT Plus/Pro.
- `omo-slim-hybrid-qwen35b-go`: Multi-provider deployment using local Qwen3.6 35B for exploration and library research, OpenAI orchestration, and opencode-go DeepSeek implementation agents.
- `omo-slim-cloud-copilot`: GitHub Copilot-only deployment via the built-in `github-copilot` provider. Every model is prefixed `github-copilot/`. No external auth plugin, no role-managed credentials or secrets, and no fallback provider. Authenticate once with `opencode auth login`.

An invalid profile name fails early with a message listing the valid values.

### Managed files

Each profile deploys `opencode.jsonc` and `tui.jsonc`. OmO Slim profiles (names beginning with `omo-slim-`) also deploy `oh-my-opencode-slim.json` and ensure the `oh-my-opencode-slim/` directory exists.

| File | Purpose |
|------|---------|
| `opencode.jsonc` | Core opencode configuration |
| `tui.jsonc` | OpenCode terminal UI configuration (OmO plugin registered for TUI extensions) |
| `oh-my-opencode-slim.json` | Oh-My-OpenCode-Slim plugin configuration |

All managed files are replaced in full on every run. Switching profiles or re-running the same profile eliminates any keys from previous or hand-edited versions because the entire file is overwritten.

### Title agent (OpenCode core)

The `title` agent in `opencode.jsonc` is an OpenCode core hidden agent that generates conversation titles from the first user message. It is **not** part of Oh-My-OpenCode-Slim — it runs directly through OpenCode's built-in agent system. The built-in title agent is already hidden by OpenCode, so no `hidden` field is needed; each profile only overrides the model (and optionally variant) for fast title generation.

| Profile | Title model | Variant |
|---------|-------------|---------|
| `omo-slim-cloud-openai` | `openai/gpt-5.5` | `fast` |
| `omo-slim-hybrid-qwen35b-go` | `opencode-go/deepseek-v4-flash` | _none_ |
| `omo-slim-cloud-copilot` | `github-copilot/raptor-mini` | `low` |

### omo-slim-cloud-openai profile

Deploys `oh-my-opencode-slim@latest` as both a core plugin and TUI plugin, enables background subagents, disables the built-in `explore` and `general` agents, enables LSP, and writes an OpenAI-only OmO preset intended for ChatGPT Plus/Pro. Title generation uses `openai/gpt-5.5` with the `fast` variant.

OmO agents:
- Orchestrator: `openai/gpt-5.6-sol-fast`
- Oracle: `openai/gpt-5.6-sol` (high)
- Librarian: `openai/gpt-5.3-codex-spark` — MCPs: websearch, context7, gh_grep
- Explorer: `openai/gpt-5.3-codex-spark`
- Designer: `openai/gpt-5.6-terra`
- Fixer: `openai/gpt-5.6-terra`

### omo-slim-cloud-copilot profile

Deploys `oh-my-opencode-slim@latest` as both a core plugin and TUI plugin, enables background subagents, disables the built-in `explore` and `general` agents, enables LSP, restricts `enabled_providers` to `["github-copilot"]`, and writes a Copilot-only OmO preset. Title generation uses `github-copilot/raptor-mini` with the `low` variant.

OmO agents:
- Orchestrator: `github-copilot/gpt-5.6-sol` (high)
- Oracle: `github-copilot/claude-sonnet-5` (high)
- Librarian: `github-copilot/gpt-5-mini` (low) — MCPs: websearch, context7, gh_grep
- Explorer: `github-copilot/gemini-3.1-pro` (low)
- Designer: `github-copilot/gemini-3.1-pro` (high)
- Fixer: `github-copilot/claude-sonnet-5` (medium)

No OpenAI, Ollama, or opencode-go preset/fallback is included. All models are routed exclusively through the built-in `github-copilot` provider. After applying the profile, authenticate once with `opencode auth login`.

### omo-slim-hybrid-qwen35b-go profile

Uses the same plugin, background-subagent, OpenAI preset, and Ollama limits as `omo-slim-cloud-openai`, but configures the local Ollama provider for `qwen3.6:35b`. The profile includes four presets: `openai`, `hybrid` (the default), `hybridgo`, and `superbudget`. Title generation uses `opencode-go/deepseek-v4-flash`.

Hybrid OmO agents:
- Orchestrator: `openai/gpt-5.6-sol` (medium)
- Oracle: `openai/gpt-5.6-sol` (high)
- Librarian: `ollama/qwen-agent` — MCPs: websearch, context7, gh_grep
- Explorer: `ollama/qwen-agent`
- Designer: `opencode-go/deepseek-v4-pro` (max)
- Fixer: `opencode-go/deepseek-v4-pro` (max)

### hybridgo preset

Uses opencode-go for orchestration and architecture review, while Librarian and Explorer remain on local `qwen-agent`. Designer and Fixer use opencode-go with max variant.

Hybridgo OmO agents:
- Orchestrator: `opencode-go/deepseek-v4-pro` (max)
- Oracle: `opencode-go/glm-5.2` (max)
- Librarian: `ollama/qwen-agent` — MCPs: websearch, context7, gh_grep
- Explorer: `ollama/qwen-agent`
- Designer: `opencode-go/deepseek-v4-pro` (max)
- Fixer: `opencode-go/deepseek-v4-pro` (max)

### superbudget preset

Cost-optimized preset. Orchestrator uses opencode-go flash variant; all other agents use local `qwen-agent`.

Superbudget OmO agents:
- Orchestrator: `opencode-go/deepseek-v4-flash` (max)
- Oracle: `opencode-go/deepseek-v4-pro` (max)
- Librarian: `ollama/qwen-agent` — MCPs: websearch, context7, gh_grep
- Explorer: `ollama/qwen-agent`
- Designer: `ollama/qwen-agent`
- Fixer: `ollama/qwen-agent`

### Auto-update and versioning

`oh-my-opencode-slim@latest` is pinned as `@latest` in plugin references, and OmO `autoUpdate` is enabled. The role does not pin or disable updates — the plugin fetches the latest compatible version at runtime.

### Authentication and secrets

This role does not manage API keys, login credentials, or provider authentication. After applying a profile, authenticate interactively:
- `opencode auth login` for ChatGPT Plus/Pro or GitHub Copilot
- `opencode models --refresh` to update the subscription model list
- For the hybrid profile with the `hybrid` preset: configure opencode-go authentication outside this role, and install/start Ollama separately (`ollama pull qwen3.6:35b`)

## Usage

Install or upgrade OpenCode only (no config changes):
```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml
```

Apply a profile:
```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=omo-slim-cloud-openai
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=omo-slim-hybrid-qwen35b-go
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_opencode.yml -e arch_opencode_profile=omo-slim-cloud-copilot
```

## Overwrite semantics

The role only writes the managed files listed above. It never removes files from `~/.config/opencode/`. Switching profiles replaces managed files with the new profile's versions; switching back to no profile (`arch_opencode_profile=""`) leaves the previously-deployed managed files in place.

Shell environment configuration (e.g., `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS`) is only written to `.bashrc` when a profile is selected. Install-only runs do not touch `.bashrc` or any config files.

Re-running the same profile is safe and idempotent: managed profile files are refreshed and Bun runs only when the installed OpenCode version differs from the resolved latest stable npm release.
