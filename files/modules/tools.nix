{ config, pkgs, ... }:

{
  # Core utilities
  home.packages = with pkgs; [
    python3
    python3Packages.requests

    # General utilities
    imagemagick
    xdg-utils
    wl-clipboard
    ffmpeg
    yt-dlp
    mpv
  ];
}
