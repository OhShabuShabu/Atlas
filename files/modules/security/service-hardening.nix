{ config, pkgs, lib, ... }:

# INFO: ============================================================================
# INFO: SYSTEMD SERVICE HARDENING (BOOT-5264)
# INFO: ============================================================================
# INFO: Enhanced systemd service hardening for security
# FIX: Service sandboxing to limit exposure (BOOT-5264)
# NOTE: Avoid aggressive hardening that can cause boot issues
# WARN: Some services may break if hardened too much

{
  # INFO: Disable core dumps at systemd level
  systemd.coredump.enable = false;

  # INFO: Disable core dumps at PAM level
  security.pam.loginLimits = [{
    domain = "*";
    type = "-";
    item = "core";
    value = "0";
  }];

  # FIX: Enhanced service hardening with sandbox options (BOOT-5264)
  # NOTE: Keep essential services working while adding protection
  systemd.services = {
    # INFO: Systemd journald - log management
    systemd-journald.serviceConfig = {
      ProtectSystem = "full";
      PrivateTmp = true;
      # FIX: Additional hardening
      ProtectHome = true;
      NoNewPrivileges = true;
    };

    # INFO: Systemd timesyncd - network time sync
    systemd-timesyncd.serviceConfig = {
      PrivateTmp = true;
      PrivateNetwork = false;  # Needs network access
      # FIX: Sandboxing
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
    };

    # INFO: Systemd logind - login manager
    systemd-logind.serviceConfig = {
      PrivateTmp = true;
      NoNewPrivileges = true;
    };

    # INFO: Systemd hostnamed - hostname service
    systemd-hostnamed.serviceConfig = {
      PrivateTmp = true;
      PrivateNetwork = true;
      NoNewPrivileges = true;
    };

    # INFO: D-Bus broker - message bus
    "dbus-broker".serviceConfig = {
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
    
    # FIX: Harden systemd-udevd (device manager) (BOOT-5264)
    systemd-udevd.serviceConfig = {
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
    
    # FIX: Harden audit daemon (BOOT-5264)
    auditd.serviceConfig = {
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  # FIX: Document service hardening best practices
  environment.etc."security/service-hardening-notes.txt".text = ''
    # Service Hardening Guidelines (Lynis BOOT-5264)
    
    Available hardening options for systemd services:
    
    - PrivateTmp: Separate /tmp for the service
    - PrivateNetwork: Isolated network namespace
    - ProtectSystem: Restrict filesystem access
      * "off" - No protection (default)
      * "strict" - Make most of / read-only
      * "full" - Make all of / read-only (except /dev, /proc, /sys, /run)
    - ProtectHome: Make /home read-only or inaccessible
    - NoNewPrivileges: Prevent privilege escalation
    - RestrictNamespaces: Limit available namespaces
    - RestrictRealtime: Disable real-time priority
    - LockPersonality: Prevent personality changes
    
    Use: systemd-analyze security SERVICE_NAME
    to check service hardening status
  '';
}