{ config, pkgs, lib, ... }:
{
    # ============================================================================
    # SECTION 6: TELEMETRY DISABLING
    # ============================================================================
    # INFO: Disable services that may leak privacy data
    services = {
        dbus.implementation = "broker";
        logrotate.enable = true;
        journald = {
            # Store logs in memory (prevents disk-based forensics)
            storage = "volatile";
            upload.enable = false;
            extraConfig = ''
                SystemMaxUse=500M
                SystemMaxFileSize=50M
            '';
        };

        # Disable telemetry services
        avahi.enable = false;
        geoclue2.enable = false;
        udisks2.enable = false;
        accounts-daemon.enable = false;
    };

    # INFO: Disable modem manager (WWAN/3G/4G not used)
    networking.modemmanager.enable = false;

    # INFO: Disable automatic system upgrades (manual control)
    system.autoUpgrade.enable = false;
}