# arch_yazi

Installs Yazi, a terminal file manager, and configures the Flexoki Dark flavor on Arch Linux hosts.

## Variables

- `arch_yazi_packages` — Packages installed via pacman. Includes `yazi` along with runtime dependencies:
  `file`, `git`, `fzf`, `ripgrep`, `fd`, `jq`, and `ttf-inconsolata-nerd`.
- `arch_yazi_flavor` — Flavor name used by `ya pkg add`. Default: `flexoki-dark`.
- `arch_yazi_flavor_package` — Flavor package identifier for `ya pkg add`. Default: `gosxrgxx/flexoki-dark`.
- `arch_yazi_ratio` — Column ratio for the three-pane layout in the order `[parent, current, preview]`.
  Default: `[1, 2, 3]`.
- `arch_yazi_obsolete_packages` — Packages removed from `ya pkg` if present (cleanup of old Solarized flavors).
  Defaults: `yazi-rs/flavors:solarized-dark` and `peterfication/solarized`.
