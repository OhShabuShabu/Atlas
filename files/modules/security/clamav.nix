{ pkgs, lib, ... }:

# INFO: ============================================================================
# INFO: CLAMAV ANTIVIRUS SCANNING
# INFO: ============================================================================
# NOTE: ClamAV scanning - runs via timer only, not on boot
# INFO: Daily scan at 3am, no boot scan to avoid rebuild delays

let
  # INFO: Directories to scan
  scanDirs = "/home /tmp /var /srv";

  # INFO: Log file path
  logFile = "/var/log/clamav/scan.log";

  # INFO: Get clamav package path
  clamav = pkgs.clamav;
  clamavBin = "${clamav}/bin";
in

{
  # INFO: Create log directory
  systemd.tmpfiles.rules = [
    "d /var/log/clamav 0750 root root -"
  ];

  # INFO: Enable ClamAV daemon and updater
  # NOTE: Daemon disabled - slow startup blocks boot. Enable manually if needed.
  services.clamav.daemon.enable = false;
  services.clamav.updater.enable = true;

  # INFO: Daily ClamAV scan - runs via timer only, not at boot
  systemd.services.clamav-daily-scan = {
    description = "Daily ClamAV virus scan";
    after = [ "network.target" "clamav-freshclam.service" ];
    wantedBy = [ ];  # INFO: Empty - no boot start, only via timer
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      StandardOutput = "journal";
      StandardError = "journal";
      ExecStart = pkgs.writeShellScript "clamav-daily-scan.sh" ''
        #!/bin/bash
        set -e

        SCAN_DIRS="${scanDirs}"
        LOG_FILE="${logFile}"
        CLAMSCAN="${clamavBin}/clamscan"

        mkdir -p "$(dirname "$LOG_FILE")"

        echo "=== ClamAV Scan $(date) ===" >> "$LOG_FILE"

        $CLAMSCAN --recursive --detect-pua=yes \
          --exclude-dir="/proc" --exclude-dir="/sys" --exclude-dir="/dev" \
          --log="$LOG_FILE" $SCAN_DIRS 2>&1 | tail -50 >> "$LOG_FILE"

        THREATS=$(grep -c "FOUND" "$LOG_FILE" 2>/dev/null || echo "0")

        if [ "$THREATS" -gt 0 ]; then
          THREAT_SUMMARY=$(grep "FOUND" "$LOG_FILE" | head -5 | tr '\n' ' ')
          /run/current-system/sw/bin/notify-send -u critical -t 10000 \
            "ClamAV Alert" "Threats detected: $THREAT_SUMMARY"
          echo "ALERT: $THREATS threats detected at $(date)" >> "$LOG_FILE"
        else
          echo "Scan completed - No threats found at $(date)" >> "$LOG_FILE"
        fi

        find /var/log/clamav -name "scan.log.*" -mtime +7 -delete 2>/dev/null || true
      '';
    };
  };

  # INFO: Timer for daily scan at 3pm
  systemd.timers.clamav-daily-scan = {
    description = "Daily ClamAV virus scan timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 15:00:00";
      Persistent = true;
    };
  };
}