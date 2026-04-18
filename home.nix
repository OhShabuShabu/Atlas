{ config, pkgs, lib, ... }:

{

  imports = [
    files/extra/flatpak.nix
    files/extra/minecraft-pack.nix
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
  "text/html" = "firefox.desktop";
  "x-scheme-handler/http" = "firefox.desktop";

  "x-scheme-handler/https" = "firefox.desktop";
  "application/pdf" = "firefox.desktop";
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

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
  
# INFO: Packages
  home.packages = with pkgs; [
    git
    fastfetch firefox fish fzf
    vesktop
    btop
    vicinae
    kitty
    opencode
    neovim
    btop
    xwayland-satellite
    lua
    adwaita-icon-theme
    papirus-icon-theme
    gnome-themes-extra
    waybar
    monocraft
    nautilus
    rofi
    spotify
    spicetify-cli
    grim
    just
    tesseract
    wl-clipboard
    libnotify
    xdg-utils
    matugen
    tty-clock
  ];

# INFO: Files
  home.file = {
    ".icons".source                               = ./files/config/.icons;
    ".config/nix".source                          = ./files/config/nix; 
    ".config/nvim".source                         = ./files/config/nvim;
    ".config/niri".source                         = ./files/config/niri;
    ".config/vicinae".source                      = ./files/config/vicinae;
    ".config/millennium".source                   = ./files/config/millennium;
    ".config/fish/functions/motivate.fish".source = ./files/bin/motivate.fish;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/yusa/etc/profile.d/hm-session-vars.sh
  #

  # Let Home Manager install and manage itself.
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
      shell = "${pkgs.fish}/bin/fish";
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

  programs.fish = {
    enable = true;
    shellInit = ''
      set -g fish_greeting
      motivate
    '';
  };
  systemd.user.startServices = true;
}
