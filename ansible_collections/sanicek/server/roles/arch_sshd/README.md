# arch_sshd

Installs and enables hardened OpenSSH server on Arch Linux compatible hosts.

## Features

- Key-based authentication only (password/auth disabled by default)
- Root login disabled (`PermitRootLogin no`)
- Modern cryptographic defaults (curve25519, chacha20-poly1305, aes-gcm)
- Hardened limits (MaxAuthTries 3, MaxStartups, LoginGraceTime)
- TCP forwarding enabled by default (required for SSH tunnels to local services like Ollama)
- X11 forwarding disabled
- Drop-in config via `/etc/ssh/sshd_config.d/hardened.conf` (OpenSSH 9.4+)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `arch_sshd_package` | `openssh` | Package name to install |
| `arch_sshd_service` | `sshd.service` | Systemd service name |
| `arch_sshd_manage_firewall` | `true` | Add UFW rules for port 22 |
| `arch_sshd_firewall_rules` | `[{port: "22", proto: tcp, rule: allow, comment: SSH}]` | Firewall rules |
| `arch_sshd_config_dropin_enable` | `true` | Deploy hardened config drop-in; removes it when false |
| `arch_sshd_permit_root_login` | `no` | Root login (`yes`, `prohibit-password`, `forced-commands-only`, `no`) |
| `arch_sshd_password_auth` | `no` | Disable password authentication |
| `arch_sshd_challenge_response_auth` | `no` | Disable challenge-response auth |
| `arch_sshd_kbd_interactive_auth` | `no` | Disable keyboard-interactive auth |
| `arch_sshd_pubkey_auth` | `yes` | Enable public key auth |
| `arch_sshd_x11_forwarding` | `no` | Disable X11 forwarding |
| `arch_sshd_allow_tcp_forwarding` | `local` | TCP forwarding (`yes`, `no`, `local`, `remote`) |
| `arch_sshd_gateway_ports` | `no` | Do not expose forwarded ports to remote interfaces |
| `arch_sshd_permit_tunnel` | `no` | Disable SSH tunneling |
| `arch_sshd_max_auth_tries` | `3` | Max auth attempts per connection |
| `arch_sshd_login_grace_time` | `60` | Seconds allowed for authentication |
| `arch_sshd_max_sessions` | `4` | Max concurrent sessions per connection |
| `arch_sshd_max_startups` | `10:30:60` | Rate limit unauthenticated connections |
| `arch_sshd_client_alive_interval` | `300` | Seconds between keepalive probes |
| `arch_sshd_client_alive_count_max` | `2` | Max missed keepalives before disconnect |
| `arch_sshd_use_dns` | `no` | Disable reverse DNS lookups (speeds up connections) |
| `arch_sshd_kex_algorithms` | `curve25519-sha256,curve25519-sha256@libssh.org` | Key exchange algorithms |
| `arch_sshd_macs` | `hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com` | MAC algorithms |
| `arch_sshd_ciphers` | `chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com` | Symmetric ciphers |

## Usage examples

### Default hardened setup (key-only auth, TCP tunneling enabled)

```bash
ansible-playbook ansible_collections/sanicek/server/playbooks/arch_sshd.yml
```

### Allow remote forwarding too (in addition to local tunnels)

```yaml
# host_vars/<host>.yml
arch_sshd_allow_tcp_forwarding: "yes"
```

### Use non-standard SSH port

```yaml
# host_vars/<host>.yml (firewall only — sshd Port is set in /etc/ssh/sshd_config)
arch_sshd_firewall_rules:
  - port: "2222"
    proto: tcp
    rule: allow
    comment: SSH custom port
```

### Disable drop-in config (use main sshd_config exclusively)

```yaml
arch_sshd_config_dropin_enable: false
```

When disabled, the role removes its managed `/etc/ssh/sshd_config.d/hardened.conf` file.

## Client SSH tunnel to local services

With `AllowTcpForwarding` enabled, set up a connection on your client:

### One-off tunnel

```bash
ssh -L 127.0.0.1:11434:127.0.0.1:11434 user@server "exec bash"
```

### Persistent config (~/.ssh/config on client)

```
Host myserver
    HostName your-server.example.com
    User youruser
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 127.0.0.1:11434 127.0.0.1:11434
    ForwardAgent no
    ServerAliveInterval 60
```

Opencode can use this tunnel transparently. When an opencode profile configures an Ollama provider (e.g., the `omo-slim-hybrid-qwen35b-go` profile sets the base URL to `http://127.0.0.1:11434/v1` in `opencode.jsonc` for its local `qwen-agent` model), the tunnel forwards traffic to the remote server.
