# arch_ollama

Installs and configures Ollama on Arch Linux compatible hosts, with support for multiple inference backends, custom model building from Modelfiles, firewall management, and optional ROCm diagnostics.

## Features

- **Multiple inference backends**: CPU (`ollama`), ROCm GPU (`ollama-rocm`, default), Vulkan (`ollama-vulkan`)
- **Service configuration via systemd override**: `OLLAMA_HOST`, `OLLAMA_KEEP_ALIVE`, `OLLAMA_CONTEXT_LENGTH`, and optional `HSA_OVERRIDE_GFX_VERSION` for ROCm
- **Optional ROCm diagnostics**: `rocminfo` and `amdgpu_top` installed when using the ROCm backend
- **UFW firewall management**: Only opens port 11434 when the host is not bound to localhost-only addresses (e.g., `127.0.0.1`, `localhost`, `::1`)
- **Model pulling**: Pulls models from the Ollama library with idempotency (skips already-present models)
- **Custom model building**: Builds custom models from Modelfile templates, with digest-based idempotency — rebuilds only when the Modelfile content, base model digest, or local model list changes
- **Service lifecycle**: Enables and starts `ollama.service`, reloads systemd and restarts the service on configuration changes

## Backend selection

Set `arch_ollama_backend` to one of the following:

| Backend | Package | Description |
|---------|---------|-------------|
| `rocm` | `ollama-rocm` | ROCm GPU acceleration (default) |
| `cpu` | `ollama` | CPU-only inference |
| `vulkan` | `ollama-vulkan` | Vulkan GPU acceleration |

The role validates the backend against supported values and fails early with a descriptive message if an unsupported backend is given.

## Custom model building

Custom models are defined via `arch_ollama_custom_models`, a list of model definitions. Each definition requires:

- `name`: The name for the custom model (e.g., `qwen-agent`)
- `base`: The base Ollama model to derive from (e.g., `qwen3.6:35b`)
- `params` (optional): List of Ollama `PARAMETER` directives (e.g., `temperature 0.2`)
- `system_prompt` (optional): A system prompt string for the model

The role templates each definition into a Modelfile at `/etc/ollama/modelfiles/<name>.Modelfile` using `templates/modelfile.j2`. The resulting Modelfile has this structure:

```
FROM <base>
PARAMETER <param1>
PARAMETER <param2>
...
SYSTEM """<system_prompt>"""
```

### Idempotency

The role tracks three change signals and rebuilds a custom model when any of them triggers:

1. **Modelfile content changed** — the rendered template differs from the previous run
2. **Base model digest changed** — the output of `ollama show <base>` has changed (persisted to `/etc/ollama/modelfiles/<name>.base-digest`)
3. **Model not present locally** — the model name is missing from `ollama list`

If none of these signals indicate a change, the model is not rebuilt.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_ollama_supported_distributions` | `[Archlinux, CachyOS]` | Distributions the role accepts |
| `arch_ollama_backend` | `rocm` | Inference backend (`cpu`, `rocm`, `vulkan`) |
| `arch_ollama_host` | `127.0.0.1:11434` | `OLLAMA_HOST` bind address and port |
| `arch_ollama_keep_alive` | `1h` | `OLLAMA_KEEP_ALIVE` duration for keeping models loaded |
| `arch_ollama_context_length` | `""` | `OLLAMA_CONTEXT_LENGTH` (empty to use model default). When opencode uses this Ollama instance via a profile (e.g., `hybrid_qwen_go`), ensure the context limit in the profile's `opencode.jsonc` matches this value. |
| `arch_ollama_rocm_hsa_override_gfx_version` | `""` | Optional `HSA_OVERRIDE_GFX_VERSION` for ROCm GPU compatibility (empty to skip) |
| `arch_ollama_models` | `[qwen3.6:35b]` | List of Ollama models to pull |
| `arch_ollama_custom_models` | See defaults | Custom model definitions (list of dicts with `name`, `base`, `params`, `system_prompt`) |
| `arch_ollama_install_diagnostics` | `true` | Install `rocminfo` and `amdgpu_top` when using ROCm backend |
| `arch_ollama_manage_firewall` | `true` | Manage UFW rules for the Ollama API port |
| `arch_ollama_firewall_rules` | `[{port: "11434", proto: tcp, rule: allow, comment: Ollama API}]` | UFW rules applied when firewall management is active and host is not localhost-only |
| `arch_ollama_packages` | `{cpu: ollama, rocm: ollama-rocm, vulkan: ollama-vulkan}` | Backend-to-package mapping |
| `arch_ollama_diagnostic_packages` | `[rocminfo, amdgpu_top]` | Diagnostic tools installed with ROCm backend |

## Usage examples

### Default setup (ROCm, localhost-only, pulls qwen3.6:35b)

```bash
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_ollama.yml
```

### CPU-only inference

```yaml
# host_vars/<host>.yml
arch_ollama_backend: cpu
```

### Vulkan backend

```yaml
# host_vars/<host>.yml
arch_ollama_backend: vulkan
```

### Bind to all interfaces and increase context length

```yaml
# host_vars/<host>.yml
arch_ollama_host: "0.0.0.0:11434"
arch_ollama_context_length: "131072"
```

When `arch_ollama_host` is set to a non-localhost address, the role automatically opens the UFW firewall port so remote clients can reach the API.

### Pull additional models

```yaml
# host_vars/<host>.yml
arch_ollama_models:
  - qwen3.6:35b
  - codellama:13b
  - nomic-embed-text
```

### Disable ROCm diagnostics

```yaml
# host_vars/<host>.yml
arch_ollama_install_diagnostics: false
```

### Disable firewall management

```yaml
# host_vars/<host>.yml
arch_ollama_manage_firewall: false
```

### Build a custom model with system prompt and tuned parameters

```yaml
# host_vars/<host>.yml
arch_ollama_custom_models:
  - name: qwen-agent
    base: qwen3.6:35b
    params:
      - temperature 0.2
      - top_p 0.9
      - top_k 20
      - repeat_penalty 1.05
      - num_ctx 131072
      - num_predict 8192
      - seed 42
    system_prompt: |
      You are a helpful AI assistant.
      Always respond concisely.
```

### ROCm GPU compatibility override

```yaml
# host_vars/<host>.yml
arch_ollama_rocm_hsa_override_gfx_version: "11.0.0"
```
