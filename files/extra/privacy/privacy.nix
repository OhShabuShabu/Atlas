{ config, pkgs, ... }:
{
  # ============================================================================
  # PRIVACY CONFIGURATION
  # ============================================================================
  # Enables: Mullvad VPN, Mullvad Browser
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
  # SECTION 2: MULLVAD BROWSER PROFILE
  # ============================================================================
  # Copy Mullvad Browser profile on startup
  systemd.services.mullvadbrowser-profile = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.mullvad-browser pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      User = "yusa";
      RemainAfterExit = true;
    };
    # Creates Mullvad directory and copies profile
    script = ''
      mkdir -p $HOME/.mullvad

      if [ -d $HOME/.mullvad ]; then
        cp -rn /home/yusa/Atlas/files/extra/privacy/mullvadbrowser/ $HOME/.mullvad/mullvadbrowser
      fi
    '';
  };
}