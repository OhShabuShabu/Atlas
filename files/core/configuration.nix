# ============================================================================
# ATLAS SYSTEM CONFIGURATION
# ============================================================================
# Main NixOS configuration file - imports all module components
# ============================================================================

{ config, pkgs, inputs, ... }:

{
  # ============================================================================
  # MODULE IMPORTS
  # ============================================================================
  imports = [
    # Core system modules
    ./hardware-configuration.nix

    # Extra feature modules
    ../extra/virtualisation.nix
    ../extra/minecraft.nix
    ../extra/security.nix
    ../extra/privacy/privacy.nix
    ../extra/gaming/gaming.nix
    ../extra/social.nix
    ../extra/flatpak.nix

    # Display manager module
    inputs.silentSDDM.nixosModules.default
  ];


  # ============================================================================
  # SECTION 1: BOOT CONFIGURATION
  # ============================================================================
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Enable systemd initrd (required for LUKS)
    initrd.systemd.enable = true;

    # LUKS encrypted root device
    initrd.luks.devices."luks-a25ffcac-804c-475f-889c-753d99a91cc6".device = "/dev/disk/by-uuid/a25ffcac-804c-475f-889c-753d99a91cc6";

    # Plymouth boot splash
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # Only install rings theme (save space)
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };

    # Silent boot - reduce console noise
    consoleLogLevel = 0;
    initrd.verbose = false;

    # Kernel parameters
    kernelParams = [
      # Display settings
      "video=1920x1080"

      # Boot options
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"

      # Systemd early boot config
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"

      # CPU performance tuning
      "amd_pstate=active"
      "tsc=reliable"

      # Hardware-specific (ASUS laptops)
      "asus_wmi"
    ];
  };


  # ============================================================================
  # SECTION 2: NETWORK CONFIGURATION
  # ============================================================================
  # Host name
  networking.hostName = "atlas";

  # Use NetworkManager
  networking.networkmanager.enable = true;

  # Disable systemd-resolved DNS (use direct nameservers)
  networking.networkmanager.dns = "none";

  # Disable DHCP client (static IP)
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  # Custom nameservers (Cloudflare + Google)
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];


  # ============================================================================
  # SECTION 3: HOME MANAGER
  # ============================================================================
  # Enable Home Manager
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";


  # ============================================================================
  # SECTION 4: NIX CONFIGURATION
  # ============================================================================
  # Enable Nix flakes and commands
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages (NVIDIA, etc.)
  nixpkgs.config.allowUnfree = true;


  # ============================================================================
  # SECTION 5: TIMEZONE & LOCALIZATION
  # ============================================================================
  # Set timezone
  time.timeZone = "Europe/Berlin";

  # Default locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Additional locale settings (German)
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


  # ============================================================================
  # SECTION 6: X SERVER & DESKTOP
  # ============================================================================
  # Enable X server
  services.xserver.enable = true;

  # Use AMD GPU drivers
  services.xserver.videoDrivers = [ "amd" ];

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Exclude xterm
  services.xserver.excludePackages = [ pkgs.xterm];


  # ============================================================================
  # SECTION 7: USER CONFIGURATION
  # ============================================================================
  # Main user account
  users.users.yusa = {
    isNormalUser = true;
    description = "yusa";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    packages = with pkgs; [];
  };


  # ============================================================================
  # SECTION 8: HARDWARE SERVICES
  # ============================================================================
  # OpenRGB for RGB control
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "intel";
    server.port = 6742;
  };

  # GPU hardware acceleration
  hardware.graphics = {
    enable = true;
  };


  # ============================================================================
  # SECTION 9: SYSTEMD SERVICES
  # ============================================================================
  # Polkit GNOME authentication agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
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


  # ============================================================================
  # SECTION 10: WINDOW MANAGER - Niri
  # ============================================================================
  # Enable Niri (Wayland compositor)
  programs.niri.enable = true;


  # ============================================================================
  # SECTION 11: QT & THEME SETTINGS
  # ============================================================================
  # Dynamic theming with Matugen colors
  environment.etc."xdg/color-schemes/SkwdMatugen.colors".source = "${config.users.users.yusa.home}/.local/share/color-schemes/SkwdMatugen.colors";

  # Distrobox configuration
  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
  '';

  # Session environment variables
  environment.sessionVariables = {
    "QT_QPA_PLATFORMTHEME" = "kde";
    "KDE_COLOR_SCHEME" = "${config.users.users.yusa.home}/.local/share/color-schemes/SkwdMatugen.colors";
  };

  # Qt configuration
  qt = {
    enable = true;
    platformTheme = "kde";
  };


  # ============================================================================
  # SECTION 12: OLLAMA (LOCAL LLM)
  # ============================================================================
  # Enable Ollama with ROCm (GPU acceleration)
  services.ollama.enable = true;


  # ============================================================================
  # SECTION 13: DISPLAY MANAGER (SDDM)
  # ============================================================================
  # Disable silentSDDM (using standard SDDM)
  programs.silentSDDM = {
    enable = false;
  };

  # SDDM configuration
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
    # Auto-login for user
    autoLogin = {
      enable = true;
      user = "yusa";
    };
  };


  # ============================================================================
  # SECTION 14: XDG PORTAL
  # ============================================================================
  # XDG portal for Flatpak support
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };


  # ============================================================================
  # SECTION 15: PERFORMANCE TUNING
  # ============================================================================
  # Enable TCP BBR congestion control (reduce latency)
  boot.kernelModules = [ "tcp_bbr" ];

  # Set CPU governor to performance (reduce frame time jitter)
  powerManagement.cpuFreqGovernor = "performance";


  # ============================================================================
  # SECTION 16: SYSTEM PACKAGES
  # ============================================================================
  # Core system packages
  environment.systemPackages = with pkgs; [
    # Quickshell (Qt-based shell)
    (let
      qs = inputs.quickshell;
      qsPkgs = qs.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in qs.packages.${pkgs.stdenv.hostPlatform.system}.default.withModules [
      qsPkgs.qt6.qtmultimedia
    ])

    # Wallpaper daemon
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww

    # Desktop components
    niri
    python3
    curl
    sqlite
    ffmpeg
    imagemagick
    inotify-tools

    # Fonts
    nerd-fonts.symbols-only
    roboto
    roboto-mono
    material-design-icons

    # Hardware control
    openrgb
    freerdp
    wtype
    wlrctl

    # Wallpaper engine support
    linux-wallpaperengine

    # AI/ML
    ollama-rocm

    # Media
    mpvpaper

    # Utilities
    jq
    appimage-run
    polkit_gnome
    zip
  ];


  # ============================================================================
  # SECTION 17: FONTS
  # ============================================================================
  # Font configuration
  fonts.packages = with pkgs; [
    udev-gothic-nf
    noto-fonts
    liberation_ttf

    # Custom Monocraft font (gaming aesthetic)
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


  # ============================================================================
  # SECTION 18: SYSTEM VERSION
  # ============================================================================
  # NixOS state version
  system.stateVersion = "25.11";
}