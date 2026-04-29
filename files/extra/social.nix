{ config, pkgs, ... }:
{
  # ============================================================================
  # SOCIAL COMMUNICATION CONFIGURATION
  # ============================================================================
  # Installs: Discord, Telegram, Vesktop
  # ============================================================================

  # ============================================================================
  # SECTION 1: SOCIAL PACKAGES
  # ============================================================================
  # Communication applications
  environment.systemPackages = with pkgs; [
    # Vesktop (custom Discord client)
    vesktop

    # Telegram Desktop
    telegram-desktop

    # Discord
    discord
  ];
}