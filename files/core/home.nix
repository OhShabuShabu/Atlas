{ config, pkgs, lib, ... }:

{
  # INFO: Home Manager imports
  imports = [
    ../modules/dev/dev.nix
    ../modules/tools.nix
    # NOTE: browser.nix is empty/placeholder - browser config is in privacy/privacy.nix
  ];

  home.username = "yusa";
  home.homeDirectory = "/home/yusa";

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = { Settings = ''gtk-application-prefer-dark-theme=1''; };
    gtk4.extraConfig = { Settings = ''gtk-application-prefer-dark-theme=1''; };
  };
  #dconf.settings = {
  #"org/virt-manager/virt-manager/connections" = {
  #  autoconnect = ["qemu:///system"];
  #  uris = ["qemu:///system"];
  #  };
  #};



  # Force dark mode for X11/XWayland apps via xsettings
  xdg.configFile."xsettingsd/Xwayland.conf".text = ''
    Net/ThemeName "Adwaita-dark"
    Net/IconThemeName "Papirus-Dark"
    Gtk/ApplicationPreferDarkTheme 1
  '';
  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  # FIX: Use sessionPath to properly prepend to PATH
  # home.sessionPath prepends to $PATH at shell startup
  # NOTE: Concatenate with home.homeDirectory to avoid literal $HOME expansion
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # Enable fontconfig for fonts
  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Monocraft" ];
    serif = [ "Monocraft" ];
    monospace = [ "Monocraft" ];
  };
  
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
  "image/jpeg" = "imv.desktop";
  "image/png" = "imv.desktop";
  "image/gif" = "firefox.desktop";
  "image/webp" = "org.gnome.eog.desktop";
  "image/heif" = "imv.desktop";
  "text/plain" = "codium.desktop";
  "text/css" = "codium.desktop";
  "application/x-shellscript" = "codium.desktop";
  "application/x-zerosize" = "codium.desktop";
  "text/html" = "librewolf.desktop";
  "x-scheme-handler/http" = "librewolf.desktop";

  "x-scheme-handler/https" = "librewolf.desktop";
  "application/pdf" = "librewolf.desktop";
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "chromium.desktop";
  "audio/mpeg" = "org.gnome.Decibels.desktop";
  "inode/directory" = "org.gnome.Nautilus.desktop";
  "video/mp4" = "mpv.desktop";
  "video/x-matroska" = "mpv.desktop";
  "video/webm" = "mpv.desktop";
  "video/ogg" = "mpv.desktop";
  "video/quicktime" = "mpv.desktop";
  "video/x-flv" = "mpv.desktop";
  "video/x-msvideo" = "mpv.desktop";
  "video/x-ms-wmv" = "mpv.desktop";
  "video/mpeg" = "mpv.desktop";
  };

  # FIX: Updated to match system stateVersion for consistency
  #      Home Manager release that your configuration is compatible with
  home.stateVersion = "25.11";
  
# INFO: Packages
  # NOTE: libnotify is required for notify-send in ClamAV and other notifications
  home.packages = with pkgs; [
    nushell 
    fzf
    btop 
    vicinae
    kitty
    xwayland-satellite
    lua
    adwaita-icon-theme
    papirus-icon-theme
    gnome-themes-extra
    waybar
    monocraft
    nautilus
    libnotify
    wl-clipboard
    xdg-utils
    mako
    tty-clock     
    matugen
  ];

# INFO: Files
  home.file = {
    ".icons".source                               = ../config/.icons;
    ".config/niri".source                         = ../config/niri;
    ".config/vicinae".source                      = ../config/vicinae;
    ".config/mako/config".source                  = ../config/mako/config;
    ".config/nushell/shellrc.nu".source           = ./config/shellrc.nu;
    ".config/nix".source                          = ./config/nix; 
  };
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "OhShabuShabu";
        email = "greens2acc@gmail.com";
      };
    };
  };
  
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    settings = {
      include = "skwd-theme.conf";
      font_family = "Monocraft";
      font_size = 13;
      shell = "${pkgs.nushell}/bin/nu";
      cursor_trail = 5;
      scrollback_indicator_opacity = 0;
      window_padding_width = 10;
      placement_strategy = "top-left";
      hide_window_decorations = "no";
      resize_debounce_time = "0 0";
      confirm_os_window_close = 0;
      background_opacity = 0.95;
      background_blur = 1;
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      "map shift+cmd+plus" = "change_font_size all +2.0";
      "map shift+cmd+minus" = "change_font_size all -2.0";
      "map shift+cmd+backspace" = "change_font_size all 14";
    };
  };
  programs.opencode.enable = true;
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
    };
    extraConfig = ''
      source ~/.config/nushell/shellrc.nu
    '';
  };
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    options = ["--cmd cd"];
  };
  systemd.user.startServices = true;
}
