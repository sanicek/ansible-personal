# arch_opencode

Installs opencode from native Arch Linux packages.

Optionally configures a global opencode Ollama provider in `~/.config/opencode/opencode.jsonc`. Existing JSON-compatible config is preserved and merged; comments in that file are not supported by this role's merge step.

Set `arch_opencode_ollama_context_length` to add a `limit.context` value to each managed Ollama model. Set `arch_opencode_ollama_output_limit` to control the paired `limit.output` value, which defaults to `8192`.

Keep `arch_opencode_ollama_context_length` aligned with the Ollama service's `arch_ollama_context_length` unless intentionally testing a lower opencode-side limit.
