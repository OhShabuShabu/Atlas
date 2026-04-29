# Atlas

A personalized NixOS 25.11 configuration built with Home Manager, focused on gaming, privacy, and a polished Wayland workflow with enterprise-grade security hardening.

## Overview

| Component | Choice |
|-----------|--------|
| **WM** | [Niri](https://github.com/YaLTeR/niri) (scrolling Wayland compositor) |
| **Display Manager** | SDDM (astronaut theme, auto-login) |
| **Shell** | [Nushell](https://www.nushell.sh/) |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| **Editor** | Neovim, VSCode/Codium |

## Features

### Desktop Experience
- **Dynamic theming** — [Matugen](https://github.com/InioX/matugen) generates colors from wallpapers, applied across GTK, Qt, Kitty, and Waybar
- **Wallpaper management** — [awww](https://github.com/end-4/awww) daemon + [skwd-wall-daemon](https://github.com/end-4/skwd-wall-daemon) for animated walls (mpvpaper, wallpaperengine)
- **Application launcher** — [Vicinae](https://github.com/vicinaehq/vicinae)
- **Status bar** — Waybar with dynamic colors
- **Notifications** — Mako

### Gaming & Performance
- **Steam** with [Millennium](https://github.com/SteamClientHomebrew/Millennium) theming overlay
- **PrismLauncher** (Minecraft with offline accounts)
- **Blockbench**, steamcmd
- AMD GPU with 32-bit drivers for gaming
- Intel CPU tuned with performance governor + `amd_pstate=active`

### Privacy & Security
- **Mullvad VPN** with auto-connect + **Mullvad Browser**
- **Librewolf** as default browser
- **Lynis** security audit with hardening index of 76/100
- **ClamAV** antivirus with daily scans and boot-time scanning
- **AIDE** file integrity monitoring with auto-initialized database
- Extensive kernel hardening (sysctl, locked modules, disabled protocols)
- Systemd service sandboxing with security profiles
- LUKS full-disk encryption

### Development & Tools
- Neovim (custom config), VSCode/Codium, opencode, claude-code
- bun runtime, Docker, Podman, Distrobox
- libvirtd + virt-manager (Windows 11 VM auto-starts)
- Nushell with zoxide integration

### System
- **Boot** — systemd-boot (EFI) with silent Plymouth splash (rings theme)
- **Audio** — startup/close sound effects
- **RGB** — OpenRGB with all plugins (server on port 6742)
- **Flatpak** — Flathub repository enabled
- **Ollama** — local LLM service (ROCm)
- **TCP BBR** congestion control + cake qdisc

## Security Hardening

This configuration has been hardened using [Lynis](https://cisofy.com/lynis/) security auditing:

### Kernel Hardening
- Kernel module loading locked after boot (`kernel.modules_disabled=1`)
- Pointer leak protection (`kernel.kptr_restrict=2`)
- Kernel log restriction (`kernel.dmesg_restrict=1`)
- eBPF restricted (`kernel.unprivileged_bpf_disabled=1`)
- SysRq disabled (`kernel.sysrq=0`)
- ASLR enabled (`kernel.randomize_va_space=2`)
- Core dumps disabled via PAM and systemd
- Performance events restricted (`kernel.perf_event_paranoid=3`)
- Kernel boot parameters: slab_nomerge, init_on_alloc=1, pti=on, lockdown=confidentiality

### Network Hardening
- Firewall enabled (nftables) with minimal open ports
- IP forwarding disabled
- Source routing disabled
- ICMP redirects disabled
- Reverse path filtering enabled
- SYN cookies enabled
- Martian logging enabled

### Service Hardening
Multiple systemd services hardened with:
- `ProtectKernelTunables=true`
- `ProtectKernelModules=true`
- `ProtectKernelLogs=true`
- `PrivateTmp=true`
- `NoNewPrivileges=true`
- `RemoveIPC=true`
- `RestrictSUIDSGID=true`

### Module Blacklisting
Blocked kernel modules:
- USB storage, FireWire, Thunderbolt
- Rare protocols: dccp, sctp, rds, tipc, atm, can
- Rare filesystems: cramfs, hfs, udf

### Antivirus (ClamAV)
- Daily scan at 3:00 AM
- Boot-time scan for early threat detection
- Desktop notifications on threat detection
- Scans: /home, /tmp, /var, /srv, /nix/store

### File Integrity (AIDE)
- Configured to monitor `/bin`, `/sbin`, `/usr`, `/etc`, `/var/lib`
- Database auto-initializes on first boot
- SHA512 checksums with ACL and extended attributes

### Password Policy
- SHA512 hashing with 10000 rounds
- Minimum 12 character password
- Maximum 90 day password age
- Minimum 7 day password age

## Quick Start

```bash
# First build (requires flakes enabled in /etc/nix/nix.conf)
sudo nixos-rebuild switch --flake .#atlas

# Update all inputs and rebuild
sudo nixos-rebuild switch --flake .#atlas --upgrade

# Just rebuild without updating
sudo nixos-rebuild switch --flake .#atlas
```

> **Note:** Ensure `experimental-features = nix-command flakes` is set in your Nix configuration before first build.

## Structure

```
atlas/
├── flake.nix                           # Inputs + outputs (nixos, home-manager)
└── files/
    ├── core/
    │   ├── configuration.nix           # System-level config
    │   ├── home.nix                   # Home Manager user config
    │   └── hardware-configuration.nix # Hardware-specific settings
    ├── config/
    │   ├── niri/                      # WM config (keybinds, layout, animations)
    │   ├── mako/                      # Notification daemon config
    │   ├── vicinae/                   # Launcher config
    │   ├── plymouth/                  # Boot splash theme
    │   └── .icons/                    # Cursor themes (oreo_black, QingyiBLZ)
    ├── extra/
    │   ├── dev/                       # Neovim config, development tools
    │   ├── gaming/                    # Steam, Millennium theming
    │   ├── privacy/                    # Mullvad browser/profile
    │   ├── security.nix                # Firewall, kernel hardening, AIDE, ClamAV
    │   ├── virtualisation.nix          # Docker, Podman, libvirtd, Distrobox
    │   ├── social.nix                  # Vesktop, Telegram
    │   ├── flatpak.nix                # Flatpak packages from Flathub
    │   └── minecraft.nix               # PrismLauncher config
    ├── audio/                          # startup.mp3, close_window.mp3
    └── bin/                            # Scripts (startup.sh, motivate, fix_rgb_color)
```

## Theming

| Layer | Setting |
|-------|---------|
| GTK | Adwaita-dark |
| Icons | Papirus-Dark |
| Fonts | Monocraft (primary), Roboto, Roboto Mono, Nerd Fonts, Material Design Icons, UDEV Gothic NF |
| Cursors | oreo_black_cursors, QingyiBLZ |
| Colors | Matugen (generated from current wallpaper) |

To regenerate colors after changing wallpaper:
```bash
matugen image /path/to/wallpaper
```

## Applications

| Category | Packages |
|----------|----------|
| **Browsers** | Librewolf (default), Mullvad Browser |
| **Gaming** | Steam (Millennium-themed), PrismLauncher, Blockbench, steamcmd |
| **Social** | Vesktop (Discord), Telegram Desktop |
| **Media** | mpv (default video), mpvpaper, linux-wallpaperengine, imv |
| **Dev** | Neovim, VSCode/Codium, opencode, claude-code, bun |
| **Utilities** | Waybar, Mako, btop, tty-clock, fzf, Nautilus, xwayland-satellite, OpenRGB |
| **Security** | Lynis, ClamAV, AIDE |

## Hardware

| Component | Configuration |
|-----------|---------------|
| CPU | Intel (performance governor, `amd_pstate=active`) |
| GPU | AMD (amdgpu driver, 32-bit support enabled) |
| Storage | LUKS encrypted root + swap |
| Boot | systemd-boot (EFI) with Plymouth splash |
| Network | TCP BBR congestion control |

## Key Bindings (Niri)

| Shortcut | Action |
|----------|--------|
| `Mod+T` | Open Kitty terminal |
| `Mod+Space` | Open Vicinae launcher |
| `Mod+Q` | Close window (with sound effect) |
| `Mod+Shift+Q` | Force kill window |
| `Mod+H/J/K/L` | Focus window (vim-style) |
| `Mod+Shift+H/J/K/L` | Move window |
| `Mod+R` | Switch to resize mode |

> See `~/.config/niri/config.kdl` for full keybinding reference.

## Security Commands

```bash
# Run Lynis security audit
sudo lynis audit system --quick

# Check AIDE integrity
sudo aide --check

# View kernel hardening status (should be 1)
cat /proc/sys/kernel/modules_disabled

# View ClamAV scan logs
cat /var/log/clamav/scan.log

# Manually run ClamAV scan
sudo systemctl start clamav-daily-scan
```

## Tips

- **Auto-started apps**: waybar, awww-daemon, vicinae server, xwayland-satellite, skwd-wall-daemon
- **Windows 11 VM** auto-starts 120s after boot via `startup.sh`
- **Nushell prompt** includes `motivate` (random dev quotes)
- **Kitty** launches with btop + tty-clock in splits
- **X11 apps** supported via xwayland-satellite

## License

This configuration is personal and shared for reference. Individual components retain their own licenses.