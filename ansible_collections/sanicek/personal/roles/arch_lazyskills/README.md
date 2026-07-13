# arch_lazyskills

Installs the lazyskills binary on Arch Linux hosts.

Downloads and installs from GitHub releases (`alvinunreal/lazyskills`), verifying the archive against the published SHA-256 checksum. The role is idempotent — it checks the installed version before downloading and only updates when the remote version differs. Supports `x86_64`/`amd64` and `aarch64`/`arm64` architectures.

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_lazyskills_version` | `latest` | Release version to install (e.g. `v1.2.3`, `1.2.3`, or `latest`). |
| `arch_lazyskills_install_dir` | `/usr/local/bin` | Directory to place the `lazyskills` binary. |
| `arch_lazyskills_github_repo` | `alvinunreal/lazyskills` | GitHub repository for the release. |
