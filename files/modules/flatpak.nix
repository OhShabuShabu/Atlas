{ config, pkgs, ... }:
{
  # ============================================================================
  # FLATPAK CONFIGURATION
  # ============================================================================
  # Enables Flatpak support with Flathub repository
  # ============================================================================

  # ============================================================================
  # SECTION 1: FLATPAK SERVICE
  # ============================================================================
  # Enable Flatpak daemon
  services.flatpak.enable = true;


  # ============================================================================
  # SECTION 2: FLATHUB REPOSITORY
  # ============================================================================
  # Add Flathub on boot
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      # Add Flathub repository
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

      # Install Bottles (Windows compatibility layer)
      flatpak install app/com.usebottles.bottles/x86_64/stable
    '';
  };


  # ============================================================================
  # SECTION 3: XDG PORTAL
  # ============================================================================
  # Enable XDG portal for Flatpak file dialogs
  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = [ "gtk" ];
    };
  };
}