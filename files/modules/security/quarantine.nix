{ pkgs, lib, ... }:

{
  systemd.tmpfiles.rules = [
    "d /etc/quarantine 0700 root root -"
  ];

  systemd.services.quarantine-setup = {
    description = "Setup sandboxed quarantine directory at /etc/quarantine";
    documentation = [ "https://github.com/oberblastmeister/trashy" ];
    before = [ "snout-daemon.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "quarantine-setup.sh" ''
        set -e
        QUARANTINE="/etc/quarantine"
        mkdir -p "$QUARANTINE"
        chmod 0700 "$QUARANTINE"
        chown root:root "$QUARANTINE"

        # Apply extended attributes for immutability where supported
        if command -v chattr &>/dev/null; then
          chattr +a "$QUARANTINE" 2>/dev/null || true
        fi

        # Create a README explaining the quarantine
        cat > "$QUARANTINE/README.txt" << 'EOF'
        ==========================================
        QUARANTINE DIRECTORY - LOCKED DOWN
        ==========================================
        This directory is for isolating suspicious or
        potentially malicious files.

        - Permissions: 0700 (root only)
        - All files placed here are automatically
          scanned by Snout + ClamAV
        - DO NOT remove files manually - use the
          trash or snout commands

        To list quarantined files:
          sudo ls -la /etc/quarantine

        To remove files safely:
          sudo trash /etc/quarantine/<filename>
        EOF

        chmod 0600 "$QUARANTINE/README.txt"

        # Bind mount with restrictive options for sandboxing
        mount --bind "$QUARANTINE" "$QUARANTINE" 2>/dev/null || true
        mount -o remount,noexec,nosuid,nodev "$QUARANTINE" 2>/dev/null || true
      '';
    };
  };

  environment.etc."quarantine-readme".text = ''
    This directory is for isolating suspicious or
    potentially malicious files.
    All files placed here are automatically scanned.
    Permissions: 0700 (root only)
  '';
}
