{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # SUDO-GUI WRAPPER MODULE
  # ============================================================================
  # Provides a GUI dialog for sudo authentication on Wayland/X11 desktops
  # This module ensures the sudo wrapper is available in system PATH
  # ============================================================================

  # FIX: Add PyQt6 and dependencies to system packages
  # This ensures PyQt6 is available for the GUI dialog
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.pyqt6
  ];

  # FIX: Configure system PATH to include user local bin
  # This ensures ~/.local/bin/sudo is found BEFORE /run/wrappers/bin/sudo
  environment.profiles = [
    "$HOME/.local/bin"
  ];

  # NOTE: The actual sudo wrapper and helper scripts are deployed via home-manager:
  #   - ~/.local/bin/sudo              (bash wrapper)
  #   - ~/.local/bin/sudo_ask.py       (PyQt6 GUI helper)
  #
  # home-manager is configured in files/core/home.nix with:
  #   - home.sessionPath = [ "$HOME/.local/bin" ]
  #   - home.packages includes python3Packages.pyqt6
  #   - home.file deploys the wrapper scripts
  #
  # The wrapper intercepts sudo calls and shows a GUI dialog for authorization
  # If PyQt6 is unavailable or not in a graphical environment, it falls back
  # to the real sudo implementation at /run/wrappers/bin/sudo
}
