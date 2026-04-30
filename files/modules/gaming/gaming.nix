{ config, pkgs, inputs, ... }:
{
  # ============================================================================
  # GAMING CONFIGURATION
  # ============================================================================
  # Enables Steam, gaming libraries, and hardware support
  # ============================================================================

  # ============================================================================
  # SECTION 1: STEAM & GAMING TOOLS
  # ============================================================================
  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Steam client
    steam

    # Steam command-line tool
    steamcmd
  ];

  # Enable Millennium overlay (custom Steam theming)
  nixpkgs.overlays = [ inputs.millennium.overlays.default ];


  # ============================================================================
  # SECTION 2: GPU CONFIGURATION
  # ============================================================================
  # Enable 32-bit libraries (required for Steam games/CS2)
  hardware.graphics = {
    enable32Bit = true;
  };


  # ============================================================================
  # SECTION 3: STEAM CONFIGURATION
  # ============================================================================
  # Enable Steam with Millennium package
  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam;
  };

  # Enable Steam Deck hardware support
  hardware.steam-hardware.enable = true;
}