{ pkgs, lib, ... }:

let
  scanDirs = "/home /tmp /var /srv";
  logFile = "/var/log/clamav/scan.log";
  clamavBin = "${pkgs.clamav}/bin";

  notifyScript = pkgs.writeShellScriptBin "clamav-notify" ''
    NOTIFY="${pkgs.libnotify}/bin/notify-send"
    SEVERITY="''${1:-normal}"
    TITLE="''${2:-ClamAV}"
    MESSAGE="''${3:-}"

    # Send notification as the desktop user
    for user in yusa; do
      uid=$(id -u "$user" 2>/dev/null || echo 1000)
      bus_path="/run/user/$uid/bus"
      if [ -S "$bus_path" ]; then
        sudo -u "$user" DBUS_SESSION_BUS_ADDRESS="unix:path=$bus_path" \
          "$NOTIFY" -u "$SEVERITY" -t 10000 "$TITLE" "$MESSAGE" 2>/dev/null || true
      fi
    done
  '';
in

{
  systemd.tmpfiles.rules = [
    "d /var/log/clamav 0750 root root -"
  ];

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  systemd.services.clamav-daemon = {
    after = [ "network.target" "freshclam.target" ];
    serviceConfig.Restart = "on-failure";
  };

  systemd.services.clamav-daily-scan = {
    description = "Daily ClamAV virus scan with desktop notifications";
    after = [ "network.target" "clamav-daemon.service" ];
    wantedBy = [];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "clamav-daily-scan.sh" ''
        set -e
        SCAN_DIRS="${scanDirs}"
        LOG_FILE="${logFile}"
        CLAMSCAN="${clamavBin}/clamscan"
        NOTIFY="${notifyScript}/bin/clamav-notify"
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "=== ClamAV Scan $(date) ===" >> "$LOG_FILE"
        $CLAMSCAN --recursive --detect-pua=yes \
          --exclude-dir="/proc" --exclude-dir="/sys" --exclude-dir="/dev" \
          --exclude-dir="/etc/quarantine" \
          --log="$LOG_FILE" $SCAN_DIRS 2>&1 | tail -50 >> "$LOG_FILE"
        THREATS=$(grep -c "FOUND" "$LOG_FILE" 2>/dev/null || echo "0")
        if [ "$THREATS" -gt 0 ]; then
          THREAT_SUMMARY=$(grep "FOUND" "$LOG_FILE" | head -5 | tr '\n' ' ')
          "$NOTIFY" critical "ClamAV Alert" "Threats detected: $THREAT_SUMMARY"
          echo "ALERT: $THREATS threats detected at $(date)" >> "$LOG_FILE"
        else
          "$NOTIFY" low "ClamAV Scan Complete" "No threats found"
          echo "Scan completed - No threats found at $(date)" >> "$LOG_FILE"
        fi
        if [ -d /etc/quarantine ] && [ "$(ls -A /etc/quarantine 2>/dev/null)" ]; then
          echo "=== Quarantine Scan $(date) ===" >> "$LOG_FILE"
          $CLAMSCAN --recursive --quiet /etc/quarantine >> "$LOG_FILE" 2>&1 || true
        fi
        find /var/log/clamav -name "scan.log.*" -mtime +7 -delete 2>/dev/null || true
      '';
    };
  };

  systemd.timers.clamav-daily-scan = {
    description = "Daily ClamAV virus scan timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
  };

  environment.systemPackages = [ notifyScript ];
}
