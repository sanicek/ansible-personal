#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP_USER="${1:-cac}"
BOOTSTRAP_SHELL="${BOOTSTRAP_SHELL:-/bin/bash}"

if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root: sudo bash $0 [username]"
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "This bootstrap expects Arch Linux or a pacman-based derivative."
  exit 1
fi

if [[ ! "$BOOTSTRAP_USER" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
  echo "Invalid Linux username: $BOOTSTRAP_USER"
  exit 1
fi

echo "Installing baseline packages..."
pacman -Syu --needed --noconfirm sudo git ansible

if id "$BOOTSTRAP_USER" >/dev/null 2>&1; then
  echo "User already exists: $BOOTSTRAP_USER"
else
  echo "Creating user: $BOOTSTRAP_USER"
  useradd -m -s "$BOOTSTRAP_SHELL" -G wheel "$BOOTSTRAP_USER"
fi

echo "Ensuring wheel membership..."
usermod -aG wheel "$BOOTSTRAP_USER"

USER_HOME="$(getent passwd "$BOOTSTRAP_USER" | cut -d: -f6)"

if [[ -z "$USER_HOME" || "$USER_HOME" == "/" ]]; then
  echo "Refusing unsafe home path for user $BOOTSTRAP_USER: '$USER_HOME'"
  exit 1
fi

echo "Ensuring home directory exists: $USER_HOME"
install -d -m 0750 -o "$BOOTSTRAP_USER" -g "$BOOTSTRAP_USER" "$USER_HOME"

echo "Configuring passwordless sudo..."
SUDOERS_FILE="/etc/sudoers.d/90-${BOOTSTRAP_USER}-nopasswd"

cat > "$SUDOERS_FILE" <<EOF
${BOOTSTRAP_USER} ALL=(ALL:ALL) NOPASSWD: ALL
EOF

chmod 0440 "$SUDOERS_FILE"

if command -v visudo >/dev/null 2>&1; then
  visudo -cf "$SUDOERS_FILE" >/dev/null
fi

echo "Bootstrap complete."
echo "User: $BOOTSTRAP_USER"
echo "Home: $USER_HOME"
echo "Installed: sudo git ansible"
