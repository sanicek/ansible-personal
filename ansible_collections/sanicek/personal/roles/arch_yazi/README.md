# arch_yazi

Installs Yazi, a terminal file manager, and configures the Solarized Dark flavor on Arch Linux hosts.

## Variables

- `arch_yazi_packages` — Packages installed via pacman. Includes `yazi` along with runtime dependencies:
  `file`, `git`, `fzf`, `ripgrep`, `fd`, `jq`, and `ttf-inconsolata-nerd`.
- `arch_yazi_flavor` — Flavor name used by `ya pack --install`. Default: `solarized`.
- `arch_yazi_flavor_package` — Flavor package identifier for `ya pack`. Default: `peterfication/solarized`.
- `arch_yazi_ratio` — Column ratio for the three-pane layout in the order `[parent, current, preview]`.
  Default: `[1, 2, 3]`.
- `arch_yazi_obsolete_packages` — Packages removed from `ya pack` if present (cleanup of old flavors).
  Default: `yazi-rs/flavors:solarized-dark`.
