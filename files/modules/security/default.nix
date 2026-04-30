{ lib, pkgs, ... }:

# INFO: ============================================================================
# INFO: SECURITY MODULE - Main entry point
# INFO: ============================================================================
# INFO: Imports all security submodules and provides security tools

{
  imports = [
    ./firewall.nix
    ./kernel-sysctl.nix
    ./kernel-boot.nix
    ./service-hardening.nix
    ./telemetry.nix
    ./banner.nix
    ./password-policy.nix
    ./network-privacy.nix
    ./aide.nix
    ./clamav.nix
    ./strong-keyring.nix
    ./auditd-config.nix
  ];

  # INFO: Security packages
  environment.systemPackages = with pkgs; [
    lynis           # INFO: Security auditing tool
    clamav         # INFO: Anti-virus scanner
    aide          # INFO: File integrity monitor
    audit         # INFO: Audit daemon
    lnav          # INFO: Log viewer TUI
    vulnix        # FIX: Package vulnerability scanner (PKGS-7398)
  ];

  # INFO: Shell aliases for security tools
  environment.etc."profile.d/90-security.nix".text = ''
    # INFO: Security log viewer using lnav
    alias logs='sudo lnav /var/log/*.log'
    alias security-logs='sudo lnav /var/log/lynis.log /var/log/audit/*.log /var/log/clamav/*.log'
    alias aide-check='sudo aide --check'
    alias lynis-scan='sudo lynis audit system --quick'
  '';
}