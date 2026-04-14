# Atlas

NixOS 25.11 configuration with Home Manager.

## Overview

- **WM**: Niri (Wayland compositor)
- **Display Manager**: SDDM (astronaut theme)
- **Shell**: Fish
- **Terminal**: Kitty
- **Editor**: Neovim

## Key Features

- Steam with [Millennium](https://github.com/SteamClientHomebrew/Millennium) for improved Linux gaming
- Custom Plymouth boot theme
- Ollama for local LLMs
- Flatpak support
- Mullvad VPN
- Docker
- [Vicinae](https://github.com/vicinaehq/vicinae) (launcher)

## Quick Start

```bash
# Build the system
sudo nixos-rebuild switch --flake .#atlas

# Update
sudo nixos-rebuild switch --flake .#atlas --update
```

## Structure

```
.
├── flake.nix              # Flake inputs and NixOS output
├── configuration.nix      # System-level configuration
├── home.nix               # Home Manager user config
└── files/
    ├── config/
    │   ├── niri/          # Niri (WM) config
    │   ├── nvim/          # Neovim config
    │   ├── vicinae/       # Vicinae launcher config
    │   ├── millennium/    # Steam/Proton config
    │   └── plymouth/     # Boot theme
    ├── extra/
    │   └── flatpak.nix    # Flatpak packages
    └── nix/
        └── nix.conf       # Nix settings
```

## Theming

- GTK: Adwaita-dark
- Icons: Papirus-Dark
- Fonts: JetBrains Nerd Font, Roboto

## Applications

- Firefox (browser)
- Spotify + Spicetify
- PrismLauncher (Minecraft)
- Vesktop (Discord)
- VLC, mpv (media)
- fastfetch (system info)

## Hardware

- Intel CPU (performance governor)
- AMD GPU (ROCm for Ollama)
- BBR network congestion control