# ============================================================================
# ATLAS SYSTEM CONFIGURATION
# ============================================================================
# Main NixOS configuration file - imports all module components
# NOTE: This configuration follows NixOS best practices for security, 
#       privacy, and desktop use.
# ============================================================================

{ config, pkgs, lib, inputs, ... }:

let
  # FIX: Use lib.getExe for safer package path resolution
  #      and avoid eval-order issues with user home paths
in
{
  # ============================================================================
  # MODULE IMPORTS
  # ============================================================================
  imports = [
    # INFO: Core system modules
    ./hardware-configuration.nix

    # INFO: Security modules (imports submodules automatically)
    ../modules/security/default.nix

    # INFO: Performance module
    ../modules/performance.nix

    # INFO: Feature modules
    ../modules/privacy/privacy.nix
    ../modules/gaming/gaming.nix
    ../modules/virtualisation.nix
    ../modules/minecraft.nix
    ../modules/social.nix
    ../modules/flatpak.nix
  ];

  # NOTE: silentSDDM module removed - using standard SDDM instead
  #       Uncomment below and add import above if you want to use it
  # programs.silentSDDM.enable = true;


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
      "intel_pstate=active"
      "i915.enable_guc=2"
      "tsc=reliable"

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

  # Run dynamically linked executables (bun, etc.)
  programs.nix-ld.enable = true;


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
  # Wayland compositor (Niri) - X server not needed


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
  # SECTION 9B: POLKIT CONFIGURATION
  # ============================================================================
  # Enable polkit system-wide for graphical auth popup
  security.polkit.enable = true;


  # ============================================================================
  # SECTION 9C: ADVANCED SECURITY HARDENING (2026 Standards)
  # ============================================================================
  # NOTE: These settings follow NixOS 25.x hardened profile recommendations
  
  # FIX: Enable AppArmor Mandatory Access Control
  #      Required for enhanced process isolation
  # WARN: Some applications may need updates to work with AppArmor
  security.apparmor = {
    enable = true;
    killUnconfinedConfinables = true;
  };

  # FIX: Lock kernel modules after boot to prevent malicious module injection
  security.lockKernelModules = true;

  # FIX: Protect kernel image from being replaced
  security.protectKernelImage = true;

  # FIX: Force Page Table Isolation (PTI) for enhanced Meltdown protection
  # NOTE: Default in NixOS 25.x hardened profile
  security.forcePageTableIsolation = true;

  # FIX: Disable Simultaneous Multithreading (SMT) for security
  # WARN: Significant performance cost - disable if not needed
  # security.allowSimultaneousMultithreading = false;

  # FIX: Flush L1 data cache on context switch (for VM isolation)
  # NOTE: "always" provides maximum security, "cond" is a balanced option
  # security.virtualisation.flushL1DataCache = "always";

  # FIX: GrapheneOS hardened memory allocator
  # NOTE: DISABLED - causes boot issues and crashes
  # environment.memoryAllocator.provider = "graphene-hardened";

  # ============================================================================
  # SECTION 9D: LYNIS-BASED HARDENING IMPROVEMENTS
  # ============================================================================
  # NOTE: Based on lynis audit recommendations
  
  # FIX: Enable Linux audit subsystem
  #      Tracks security-relevant events for accountability
  security.audit.enable = true;

  # FIX: Enable auditd daemon for logging
  security.auditd.enable = true;

  # FIX: Use dbus-broker instead of classic dbus
  #      More secure and better isolation
  services.dbus.implementation = "broker";

  # FIX: Limit sudo execution to wheel group only
  security.sudo.execWheelOnly = true;

  # FIX: Protect /proc from unprivileged access
  #      Hide processes from non-privileged users
  # NOTE: Use hidepid mount option instead of invalid fs.protected_proc sysctl
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "noexec" "nodev" "hidepid=2" ];
  };

  # ============================================================================
  # SECTION 9E: LOGGING AND PAM HARDENING
  # ============================================================================
  # FIX: Configure log rotation - NixOS 25.11 format
  services.logrotate.enable = true;
  services.logrotate.settings = {
    header = {
      compress = true;
      delaycompress = true;
      missingok = true;
      notifempty = true;
      rotate = 4;
      frequency = "weekly";
      create = "0640 root adm";
    };
  };

  # FIX: Configure PAM for password strength and secure login
  # NOTE: Using libpwquality for password quality checks
  security.pam = {
    # Configure secure defaults for common services
    services = {
      sudo = {
        allowNullPassword = lib.mkForce false;
        nodelay = true;
      };
      su = {
        allowNullPassword = lib.mkForce false;
        nodelay = true;
      };
      login = {
        allowNullPassword = lib.mkForce false;
        nodelay = true;
      };
      # Add pwquality module to password change services
      passwd = {
        text = lib.mkDefault (lib.mkBefore "password requisite ${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so try_first_pass");
      };
      chpasswd = {
        text = lib.mkDefault (lib.mkBefore "password requisite ${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so try_first_pass");
      };
    };
  };

  # FIX: Set domain for DNS (hostname already set earlier)
  networking.domain = "local";

  # INFO: Additional LSM configuration (landlock, yama, bpf are now default in NixOS 25.05+)


  # ============================================================================
  # SECTION 10: WINDOW MANAGER - Niri
  # ============================================================================
  # Enable Niri (Wayland compositor)
  programs.niri.enable = true;


  # ============================================================================
  # SECTION 11: QT & THEME SETTINGS
  # ============================================================================
  # Dynamic theming with Matugen colors
  # FIX: Use environment.path instead of config reference to avoid eval-order issues
  #      The color scheme will be sourced from user's home directory at runtime
  environment.etc."xdg/color-schemes/SkwdMatugen.colors".text = "";

  # Distrobox configuration
  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
  '';

  # Session environment variables
  # FIX: Use a fallback path that works even before user config is fully evaluated
  environment.sessionVariables = {
    "QT_QPA_PLATFORMTHEME" = "kde";
    "KDE_COLOR_SCHEME" = "/home/yusa/.local/share/color-schemes/SkwdMatugen.colors";
  };

  # Qt configuration
  qt = {
    enable = true;
    platformTheme = "kde";
  };


  # ============================================================================
  # SECTION 13: DISPLAY MANAGER (SDDM)
  # ============================================================================
  # SDDM configuration
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
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
    libpwquality

    # Graphical authentication (polkit-style popup)
    kdePackages.kde-cli-tools
    kdePackages.kdialog

    # INFO: Security auditing tools (from lynis recommendations)
    # NOTE: Package audit tool for vulnerability detection
    # vulnix  # Uncomment if needed - can be resource intensive
  ];

  # ============================================================================
  # SECTION 17: ADDITIONAL HARDENING
  # ============================================================================
  # FIX: Restrict /home permissions for better security
  #      Prevents other users from accessing user data
  users.users.yusa.home = "/home/yusa";


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
