# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./files/nix/hardware-configuration.nix
      ./files/extra/virtualisation.nix
      inputs.silentSDDM.nixosModules.default
    ];

  # INFO: BOOT
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true; 
    initrd.luks.devices."luks-a25ffcac-804c-475f-889c-753d99a91cc6".device = "/dev/disk/by-uuid/a25ffcac-804c-475f-889c-753d99a91cc6";
    initrd.systemd.enable = true;
    
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };



    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "video=1920x1080"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "amd_pstate=active" 
      "tsc=reliable" 
      "asus_wmi"
    ];
    
  };

  # INFO: Networking
  networking.hostName = "atlas"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Home Manager
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";

  nixpkgs.overlays = [ inputs.millennium.overlays.default ]; # Steam support with Millennium

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # INFO: i18n
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amd" ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.yusa = {
    isNormalUser = true;
    description = "yusa";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true; # Allow unfree packages

  # INFO: Enables
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  services.hardware.openrgb = { 
    enable = true; 
    package = pkgs.openrgb-with-all-plugins; 
    motherboard = "intel"; 
    server.port = 6742; 
  };

  
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["yusa"];

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };


virtualisation.spiceUSBRedirection.enable = true;

  programs.niri.enable = true;
  services.mullvad-vpn.enable = true;
  programs.steam = {
    enable = true;
    package = pkgs.millennium-steam;
  };
  environment.etc."xdg/color-schemes/SkwdMatugen.colors".source = "/home/yusa/.local/share/color-schemes/SkwdMatugen.colors";
  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
  '';

  environment.sessionVariables = {
    "QT_QPA_PLATFORMTHEME" = "kde";
    "KDE_COLOR_SCHEME" = "/home/yusa/.local/share/color-schemes/SkwdMatugen.colors";
  };

  qt = {
    enable = true;
    platformTheme = "kde";
  };

  services.flatpak.enable = true;
  hardware.steam-hardware.enable = true;
  services.ollama.enable = true;

  programs.silentSDDM = {
    enable = false;
  };


  environment.systemPackages = with pkgs; [
    (let
      qs = inputs.quickshell;
      qsPkgs = qs.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in qs.packages.${pkgs.stdenv.hostPlatform.system}.default.withModules [
      qsPkgs.qt6.qtmultimedia
    ])
    niri
    python3
    curl
    mullvad
    waybar
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    curl
    sqlite
    ffmpeg
    imagemagick
    inotify-tools
    nerd-fonts.symbols-only
    roboto
    roboto-mono
    material-design-icons
    matugen
    wtype
    wlrctl
    linux-wallpaperengine
    ollama-rocm
    steamcmd
    mpvpaper
    jq
    appimage-run
    git
    polkit_gnome
    dnsmasq
    zip
    openrgb
    freerdp
    distrobox
    ];

  # INFO: Fonts
  fonts.packages = with pkgs; [
    udev-gothic-nf
    noto-fonts
    liberation_ttf
    (pkgs.stdenv.mkDerivation {
      pname = "monocraft";
      version = "4.2.1";
      src = pkgs.fetchurl {
        url = "https://github.com/IdreesInc/Monocraft/releases/download/v4.2.1/Monocraft-otf.zip";
        hash = "sha256-5iO3LxAhBirQFWzEH1SxCOcL014rKVEnR1u1ctit5h0=";
      };
      nativeBuildInputs = [ pkgs.unzip ];
      installPhase = ''
        mkdir -p $out/share/fonts/otf
        unzip -j $src -d $out/share/fonts/otf "*.otf"
      '';
    })
  ]; 
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = false;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs; [
        sddm-astronaut
        kdePackages.qtmultimedia
      ];
    };
    autoLogin = {
      enable = true;
      user = "yusa";
    };
  };

  # XDG Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
  

  # INFO: Performance
  boot.kernelModules = [ "tcp_bbr" ];               # FIX: network congestion control (helps with packet jitter)
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.core.wmem_max" = 1073741824;
    "net.core.rmem_max" = 1073741824;
    "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
    "net.ipv4.tcp_wmem" = "4096 87380 1073741824";
  };
  powerManagement.cpuFreqGovernor = "performance";  # FIX: Force CPU to run at max clock speed to prevent frame-time jitter

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam/CS2
  };

  system.stateVersion = "25.11";
}
