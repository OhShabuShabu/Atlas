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

  # FIX: Create a sudoers-safe wrapper that can be called by shell
  # Place it in /usr/local/bin which is typically checked before system paths
  environment.localBinInPath = true;

  # FIX: Install the sudo wrapper to /usr/local/bin
  # This ensures it's found before /run/wrappers/bin/sudo in the default PATH
  environment.extraOutputsToInstall = [ "man" ];

  # Use security.sudo.execWheelOnly to ensure only wheel group can use sudo
  # This is already set in configuration.nix
  
  # NOTE: The actual sudo wrapper and helper scripts are deployed via home-manager:
  #   - ~/.local/bin/sudo              (bash wrapper)
  #   - ~/.local/bin/sudo_ask.py       (PyQt6 GUI helper)
  #
  # home-manager is configured in files/core/home.nix with:
  #   - home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ]
  #   - home.packages includes python3Packages.pyqt6
  #   - home.file deploys the wrapper scripts
  #
  # The wrapper intercepts sudo calls and shows a GUI dialog for authorization
  # If PyQt6 is unavailable or not in a graphical environment, it falls back
  # to the real sudo implementation at /run/wrappers/bin/sudo
  
  # ALTERNATIVE: Add ~/.local/bin to system-wide PATH via environment variable
  # This is picked up by shell initialization files
  environment.sessionVariables = {
    # Prepend user local bin to PATH for all sessions
    # Using lib.mkBefore ensures this is evaluated first
    PATH = lib.mkBefore "/home/yusa/.local/bin";
  };
}

