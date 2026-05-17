# Atlas

A personalized NixOS 25.11 configuration built with Home Manager, featuring the Noctalia desktop shell, enterprise-grade security hardening, gaming optimizations, and a privacy-first browsing setup.

## Overview

| Component | Choice |
|-----------|--------|
| **WM** | [Niri](https://github.com/YaLTeR/niri) (scrolling Wayland compositor) |
| **Shell** | [Noctalia](https://github.com/noctalia-dev/noctalia-shell) (Wayland desktop shell) |
| **Display Manager** | SDDM (astronaut theme, auto-login) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) with Nushell |
| **Editor** | Neovim (LazyVim), opencode |

## Features

### Desktop Experience
- **Noctalia Shell** — Sleek Wayland desktop shell (status bar, notifications, OSD, widgets)
- **Dynamic theming** — [Matugen](https://github.com/InioX/matugen) generates colors from wallpapers, applied across GTK, Qt, and Kitty
- **Wallpaper management** — [awww](https://github.com/end-4/awww) daemon for animated wallpapers
- **Application launcher** — [Vicinae](https://github.com/vicinaehq/vicinae)
- **Notifications** — Mako + Noctalia notification system

### Gaming & Performance
- **Steam** with [Millennium](https://github.com/SteamClientHomebrew/Millennium) theming overlay
- **PrismLauncher** (Minecraft with offline accounts)
- **Blockbench**, steamcmd
- AMD GPU with 32-bit drivers for gaming
- Intel CPU tuned with performance governor

### Privacy & Security
- **Mullvad VPN** with auto-connect + **Mullvad Browser**
- **Librewolf** as default browser
- **Lynis** security auditing
- **ClamAV** daemon with daily scans, real-time quarantine monitoring, and desktop notifications
- **Snout** — security monitoring daemon that watches /etc/quarantine and integrates with ClamAV
- **AIDE** file integrity monitoring with daily checks
- **Quarantine** — sandboxed, locked-down directory at /etc/quarantine with noexec,nosuid,nodev
- Extensive kernel hardening (sysctl, locked modules, disabled protocols)
- Systemd service sandboxing with security profiles
- LUKS full-disk encryption

### Development & Tools
- Neovim (custom LazyVim config), opencode, claude-code
- bun runtime, Docker, Podman, Distrobox
- libvirtd + virt-manager (Windows 11 VM)
- Nushell with zoxide integration

### System
- **Boot** — systemd-boot (EFI) with silent Plymouth splash
- **Audio** — startup/close sound effects
- **RGB** — OpenRGB
- **Flatpak** — Flathub repository enabled
- **Ollama** — local LLM service (ROCm)
- **TCP BBR** congestion control + cake qdisc
- **Trashy** — CLI system trash manager (safer alternative to rm)

## Structure

```
atlas/
├── flake.nix                           # Nix flake inputs + outputs
└── files/
    ├── core/
    │   ├── configuration.nix           # System-level config
    │   ├── home.nix                    # Home Manager user config
    │   └── hardware-configuration.nix  # Hardware-specific settings
    ├── config/
    │   ├── niri/                       # WM config (keybinds, layout, animations)
    │   ├── mako/                       # Notification daemon config
    │   ├── vicinae/                    # Launcher config
    │   ├── plymouth/                   # Boot splash theme
    │   └── .icons/                     # Cursor themes
    ├── modules/
    │   ├── security/                   # Snout, ClamAV, AIDE, auditd, kernel, firewall
    │   ├── dev/                        # Neovim, development tools
    │   ├── gaming/                     # Steam, Millennium theming
    │   ├── privacy/                    # Mullvad VPN + browser
    │   ├── social.nix                  # Vesktop, Telegram
    │   ├── flatpak.nix                 # Flatpak packages
    │   └── minecraft.nix               # PrismLauncher config
    ├── audio/                          # Sound effects
    └── bin/                            # Scripts (startup, motivate, fix_rgb_color)
```

## Security Hardening

### Kernel Hardening
- Kernel module loading locked after boot
- Pointer leak protection, kernel log restriction
- eBPF restricted, SysRq disabled
- ASLR enabled, core dumps disabled
- Boot params: slab_nomerge, init_on_alloc, pti=on, lockdown=integrity

### Network Hardening
- nftables firewall with minimal open ports
- ICMP redirects disabled, source routing disabled
- SYN cookies, reverse path filtering, martian logging

### Snout Daemon
The Snout security monitoring daemon runs as a systemd service and:
- Watches /etc/quarantine for new files via inotify
- Triggers automatic ClamAV scans on quarantined files
- Sends desktop notifications on security events
- Provides CLI interface: `snout scan`, `snout status`, `snout logs`

### Quarantine
The /etc/quarantine directory is sandboxed with:
- Permissions 0700 (root only)
- Bind-mounted with noexec, nosuid, nodev
- Automatically monitored by Snout + ClamAV

### ClamAV Daemon
- Enabled as a persistent daemon with automatic updates
- Daily system scans at 3:00 AM with randomized delay
- Separate quarantine directory scanning
- Desktop notifications on threat detection and clean scans

### File Integrity (AIDE)
- Monitors /bin, /sbin, /usr, /etc, /var/lib
- Database auto-initializes on first boot
- Daily integrity checks with SHA512 checksums

## Quick Start

```bash
# First build (requires flakes enabled in /etc/nix/nix.conf)
sudo nixos-rebuild switch --flake .#atlas

# Update all inputs and rebuild
sudo nixos-rebuild switch --flake .#atlas --upgrade

# Just rebuild without updating
sudo nixos-rebuild switch --flake .#atlas
```

## Security Commands

```bash
# Snout security monitoring
snout scan          # Run security scan and report status
snout status        # Check daemon status
snout logs          # Follow daemon logs

# ClamAV
sudo systemctl start clamav-daily-scan    # Manual scan
cat /var/log/clamav/scan.log              # View scan results

# AIDE
sudo aide --check                         # Check file integrity

# Lynis audit
sudo lynis audit system --quick

# Trash management
trash put <file>        # Move file to trash
trash list              # List trashed files
trash restore <file>    # Restore from trash

# Quarantine
sudo ls -la /etc/quarantine               # List quarantined files
sudo trash put /etc/quarantine/<file>     # Remove from quarantine
```

## Applications

| Category | Packages |
|----------|----------|
| **Browsers** | Librewolf (default), Mullvad Browser |
| **Gaming** | Steam (Millennium-themed), PrismLauncher, Blockbench |
| **Social** | Vesktop (Discord), Telegram Desktop |
| **Media** | mpv, mpvpaper, linux-wallpaperengine, imv |
| **Dev** | Neovim (LazyVim), opencode, claude-code, bun |
| **Security** | Snout, ClamAV, AIDE, Lynis, auditd |
| **Utilities** | Noctalia, Mako, btop, tty-clock, fzf, trashy, Nautilus |

## Theming

| Layer | Setting |
|-------|---------|
| GTK | Adwaita-dark |
| Icons | Papirus-Dark |
| Fonts | Monocraft, Roboto, Nerd Fonts, Material Design Icons |
| Cursors | oreo_black_cursors, QingyiBLZ |
| Colors | Matugen (generated from wallpaper) |
| Shell | Noctalia (Catppuccin Mocha theme) |

## Key Bindings (Niri)

| Shortcut | Action |
|----------|--------|
| `Mod+T` | Open Kitty terminal |
| `Mod+Space` | Open Vicinae launcher |
| `Mod+H/J/K/L` | Focus window (vim-style) |
| `Mod+Shift+W` | Noctalia panel toggle |
| `Print` | Screenshot |
| `Mod+Shift+E` | Quit Niri |

> See `~/.config/niri/config.kdl` for full keybinding reference.

## License

This configuration is personal and shared for reference. Individual components retain their own licenses.
