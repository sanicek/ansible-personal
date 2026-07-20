# arch_gz302ea_audio

Configures speaker audio for the ASUS ROG Flow Z13 2025 GZ302EA with the Realtek ALC294 codec and two CS35L41 amplifiers. It selects the packaged 19.5 dB speaker-protection amplifier configuration and runs an EasyEffects output preset through a headless user service.

The role uses `user_name` and `user_home` from `arch_bootstrap`, so configuration belongs to the user who invokes the playbook. It does not patch the kernel, set module options, replace calibration files, or disable CS35L41 speaker protection.

## Variables

- `arch_gz302ea_audio_firmware_gain`: packaged amplifier configuration to select; `19_5dB` by default, or `15_5dB` for the distro default.
- `arch_gz302ea_audio_easyeffects_enabled`: enable and run the EasyEffects user service; defaults to `true`.
- `arch_gz302ea_audio_manage_runtime`: manage the live user service and EasyEffects state; defaults to `true`. Set to `false` only for offline or container provisioning without a user systemd instance.

## Reboot and verification

Reboot after the playbook changes the firmware links. Then check the two amplifiers:

```bash
journalctl -b -k --grep='Firmware Loaded - Type: spk-prot, Gain:'
journalctl -b -k --grep='Calibration applied|CS35L41 Bound'
```

Both firmware lines must report `Gain: 19`, and both amplifiers must report `Calibration applied` and `CS35L41 Bound`.

Verify EasyEffects as the playbook user:

```bash
systemctl --user is-enabled easyeffects.service
systemctl --user is-active easyeffects.service
systemctl --user show easyeffects.service -p ExecStart -p Environment
easyeffects --last-loaded-preset output
wpctl status
```

The service must be enabled and active, `ExecStart` must contain `--service-mode --hide-window`, the environment must contain `QT_QPA_PLATFORM=offscreen`, and the last output preset must be `GZ302-Metal`. `wpctl status` must show `Easy Effects Sink`, with playback streams routed through it. No EasyEffects GUI should appear.

## Rollback

Select the managed distro 15.5 dB amplifier fallback and disable software processing:

```bash
ansible-playbook ansible_collections/sanicek/personal/playbooks/arch_gz302ea_audio.yml \
  -e arch_gz302ea_audio_firmware_gain=15_5dB \
  -e arch_gz302ea_audio_easyeffects_enabled=false
```

Reboot after restoring the firmware links. The pacman hook preserves the selected rollback value across `linux-firmware-cirrus` upgrades.
