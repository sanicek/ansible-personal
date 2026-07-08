# arch_ollama

Installs and configures Ollama on Arch Linux compatible hosts.

The default backend is `ollama-rocm`, which includes the runtime pieces Ollama needs for ROCm inference. Full ROCm development packages are not installed.

Set `arch_ollama_context_length` to configure `OLLAMA_CONTEXT_LENGTH` for the Ollama service. If opencode is configured to use this Ollama instance, keep its `arch_opencode_ollama_context_length` aligned with this value.
