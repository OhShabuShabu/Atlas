{ config, pkgs, lib, ... }:

let
  # FIX: Make username configurable via options
  #      Default to 'yusa' but can be overridden
  username = "yusa";
  userHome = "/home/${username}";
in
{
  # ============================================================================
  # PRIVACY CONFIGURATION
  # ============================================================================
  # Enables: Mullvad VPN, Mullvad Browser
  # NOTE: This module is configured for user 'yusa' by default
  #       To change users, update the 'username' variable above
  # ============================================================================

  # ============================================================================
  # SECTION 1: PRIVACY PACKAGES
  # ============================================================================
  # Privacy-focused applications
  environment.systemPackages = with pkgs; [
    # Mullvad VPN client
    mullvad-vpn

    # Mullvad Browser (privacy-focused Firefox)
    mullvad-browser
  ];
  services.mullvad-vpn.enable = true;


  # ============================================================================
  # SECTION 2: MULLVAD BROWSER PROFILE SETUP
  # ============================================================================
  # INFO: Create Mullvad directory on user login
  # NOTE: Creates .mullvad directory structure for Mullvad Browser
  systemd.services.setup-mullvad-dirs = {
    description = "Setup Mullvad directories";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = username;
    };
    script = ''
      export HOME="${userHome}"
      mkdir -p "$HOME/.mullvad"
      mkdir -p "$HOME/.local/share/mullvad-browser"
      echo "Mullvad directories created"
    '';
  };
}