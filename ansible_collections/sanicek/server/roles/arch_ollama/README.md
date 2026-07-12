# arch_ollama

Installs and configures Ollama on Arch Linux compatible hosts.

The default backend is `ollama-rocm`, which includes the runtime pieces Ollama needs for ROCm inference. Full ROCm development packages are not installed.

Set `arch_ollama_context_length` to configure `OLLAMA_CONTEXT_LENGTH` for the Ollama service. When opencode uses this Ollama instance via a profile (e.g., `hybrid_qwen_go`), ensure the context limit in the profile's `opencode.jsonc` matches this value.
