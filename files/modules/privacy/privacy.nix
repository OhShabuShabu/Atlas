{ config, pkgs, lib, ... }:

let
  username = "yusa";
  userHome = "/home/${username}";
in
{
  # ============================================================================
  # PRIVACY MODULE
  # ============================================================================
  # INFO: Configures privacy-focused applications and metadata cleaning
  # NOTE: Default user is 'yusa' - update 'username' to change

  environment.systemPackages = with pkgs; [
    # Mullvad VPN client
    mullvad-vpn

    # Privacy-focused browser
    mullvad-browser

    # Metadata cleaning tools
    exiftool
    bash
    inotify-tools
  ];
  services.mullvad-vpn.enable = true;

  # ============================================================================
  # SECTION 1: METADATA CLEANER
  # ============================================================================
  # INFO: Removes identifying metadata from pictures and videos
  # NOTE: Cleans GPS, camera serial, maker notes, thumbnails, XMP data

  systemd.services.metadata-cleaner = {
    description = "Clean metadata from pictures and videos";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'for dir in /tmp ${userHome}/Pictures ${userHome}/Downloads ${userHome}/Videos ${userHome}/Documents; do [ -d \"$dir\" ] && ${pkgs.exiftool}/bin/exiftool -overwrite_original -all= -gps:all= -makernotes:all= -Thumbnail-Image= -XMP-iptcCore:all= -XMP-dc:all= -XMP-photoshop:all= -Software= -Artist= -Copyright= -SerialNumber= -CameraSerialNumber= -r -ext jpg -ext jpeg -ext png -ext gif -ext bmp -ext tiff -ext raw -ext cr2 -ext nef -ext arw -ext dng -ext webp -ext mp4 -ext mov -ext avi -ext mkv -ext webm -ext m4v -ext 3gp -ext wmv \"$dir\" 2>/dev/null; done'";
      PrivateTmp = false;
    };
  };

  systemd.services.metadata-watcher = {
    description = "Watch directories for new media files and clean metadata";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeScript "metadata-watcher.sh" ''
        #!${pkgs.bash}/bin/bash
        dirs=""
        for d in /tmp ${userHome}/Pictures ${userHome}/Downloads ${userHome}/Videos ${userHome}/Documents; do
          [ -d "$d" ] && dirs="$dirs $d"
        done
        exts="jpg jpeg png gif bmp tiff raw cr2 nef arw dng webp mp4 mov avi mkv webm m4v 3gp wmv"
        while true; do
          ${pkgs.inotify-tools}/bin/inotifywait -q -e create -e modify -e close_write --format %w%f $dirs 2>/dev/null |
          while read file; do
            ext=$(echo "$file" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')
            for e in $exts; do
              if [ "$ext" = "$e" ]; then
                sleep 0.5
                ${pkgs.exiftool}/bin/exiftool -P -overwrite_original \
                  -all= -gps:all= -makernotes:all= -Thumbnail-Image= \
                  -XMP-iptcCore:all= -XMP-dc:all= -XMP-photoshop:all= \
                  -Software= -Artist= -Copyright= -SerialNumber= \
                  -CameraSerialNumber= -ImageNumber= -OwnerName= \
                  "$file" 2>/dev/null
                break
              fi
            done
          done
        done
      ''}";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  # ============================================================================
  # SECTION 2: MULLVAD BROWSER SETUP
  # ============================================================================
  # INFO: Creates Mullvad directories on user login

  systemd.services.setup-mullvad-dirs = {
    description = "Setup Mullvad directories";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = username;
    };
    script = ''
      export HOME="${userHome}"
      mkdir -p "$HOME/.mullvad"
      mkdir -p "$HOME/.local/share/mullvad-browser"
    '';
  };
}
