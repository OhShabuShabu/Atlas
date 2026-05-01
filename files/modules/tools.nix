{ config, pkgs, ... }:

{
  # Google Lens and Music Recognition Tools
  home.packages = with pkgs; [
    # Core
    python3
    python3Packages.requests

    # Google Lens dependencies
    imagemagick           # identify command for image analysis
    xdg-utils            # xdg-open for browser integration
    wl-clipboard         # Clipboard access (Wayland)

    # Music Recognition dependencies
    ffmpeg               # Audio recording and conversion
    chromaprint          # Audio fingerprinting
    yt-dlp              # Download audio from URLs

    # Optional: Additional tools
    sox                  # Sound eXchange - audio processing
    mpv                  # Audio playback
  ];

  # Configuration files
  home.file = {
    ".config/google-lens/config.json".text = ''
      {
        "browser": "librewolf",
        "cache_dir": "${config.home.homeDirectory}/.cache/google-lens",
        "auto_open_results": false
      }
    '';

    ".config/music-recognition/config.json".text = ''
      {
        "shazam_api_key": "",
        "cache_dir": "${config.home.homeDirectory}/.cache/music-recognition",
        "recording_quality": "high",
        "recognition_timeout": 30
      }
    '';
  };

  # Add activation script to symlink tools to ~/.local/bin
  home.activation = {
    installTools = config.lib.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.local/bin
      ln -sf ${pkgs.python3}/bin/python3 $HOME/.local/bin/python3-tools
    '';
  };
}
