{ config, pkgs, lib, ... }:
{
    # ============================================================================
    # SECURITY HARDENING CONFIGURATION
    # ============================================================================
    # This file contains enterprise-grade security hardening for NixOS
    # Includes: firewall, kernel hardening, service sandboxing, AIDE, ClamAV
    #
    # Module structure:
    #   - Firewall configuration
    #   - Kernel hardening (sysctl, boot params, module blocking)
    #   - Systemd service hardening
    #   - Password policy
    #   - File integrity monitoring (AIDE)
    #   - Antivirus scanning (ClamAV)
    # ============================================================================

    # ============================================================================
    # SECTION 1: FIREWALL CONFIGURATION
    # ============================================================================
    # INFO: Enable nftables firewall with minimal open ports
    networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPortRanges = [    
            { from = 4000; to = 4007; }
            { from = 8000; to = 8010; }
        ];
    };

    # INFO: Ensure firewall service is running (NixOS uses nftables)
    systemd.services.firewall.enable = true;


    # ============================================================================
    # SECTION 2: KERNEL HARDENING - sysctl parameters
    # ============================================================================
    # INFO: Critical kernel security settings for attack prevention
    boot.kernel.sysctl = {
        # Prevent core dumps from setuid programs (data leakage)
        "fs.suid_dumpable" = 0;

        # Restrict kernel pointer visibility (prevent kernel pointer leaks)
        "kernel.kptr_restrict" = 2;

        # Restrict kernel log access to privileged users
        "kernel.dmesg_restrict" = 1;

        # Disable unprivileged eBPF (prevents eBPF-based exploits)
        "kernel.unprivileged_bpf_disabled" = 1;

        # Prevent loading unauthorized TTY line disciplines
        "dev.tty.ldisc_autoload" = 0;

        # Disable userfaultfd (prevents use-after-free exploits)
        "vm.unprivileged_userfaultfd" = 0;

        # Prevent kexec (disable dynamic kernel loading)
        "kernel.kexec_load_disabled" = 1;

        # Disable SysRq completely (prevents keyboard-based attacks)
        "kernel.sysrq" = 0;

        # Restrict user namespaces (required for Docker/Nix/Home Manager)
        "kernel.unprivileged_userns_clone" = 1;

        # Restrict perf_event usage (prevents perf-based exploits)
        "kernel.perf_event_paranoid" = 3;

        # Enable SYN cookies (prevent SYN flood DoS attacks)
        "net.ipv4.tcp_syncookies" = 1;

        # Prevent TIME-WAIT assassination
        "net.ipv4.tcp_rfc1337" = 1;

        # Enable reverse path filtering (prevent IP spoofing)
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;

        # Disable ICMP redirects (prevent MITM attacks)
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;

        # Disable send redirects
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;

        # Ignore ICMP echo requests (prevent ICMP-based attacks)
        "net.ipv4.icmp_echo_ignore_all" = 1;

        # Disable IP forwarding (prevent system from acting as router)
        "net.ipv4.conf.all.forwarding" = 0;
        "net.ipv6.conf.all.forwarding" = 0;

        # Disable source routing (prevent routing attacks)
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;

        # Disable router advertisements (prevent RA attacks)
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv6.conf.default.accept_ra" = 0;

        # Additional hardening from Lynis audit
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        "kernel.core_uses_pid" = 1;
        "net.core.bpf_jit_harden" = 2;
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.default.log_martians" = 1;

        # Restrict ptrace (prevents process debugging exploits)
        "kernel.yama.ptrace_scope" = 2;

        # ASLR memory protection (randomize memory addresses)
        "vm.mmap_rnd_bits" = 32;
        "vm.mmap_rnd_compat_bits" = 16;

        # File system protection
        "fs.protected_symlinks" = 1;
        "fs.protected_hardlinks" = 1;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;

        # Enable address space randomization
        "kernel.randomize_va_space" = 2;

        # Enable exec shield (DEP/NX-like protection)
        "kernel.exec-shield" = 1;

        # TCP optimization (performance, not security)
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
    };

    # ============================================================================
    # SECTION 3: KERNEL BOOT PARAMETERS
    # ============================================================================
    # INFO: Kernel command-line hardening
    boot.kernelParams = [
        # Disable kernel slab merging (mitigate slab cache attacks)
        "slab_nomerge"

        # Zero memory on allocation (prevent use-after-free)
        "init_on_alloc=1"
        "init_on_free=1"

        # Randomize page allocator freelist
        "page_alloc.shuffle=1"

        # Enable Page Table Isolation (mitigate Meltdown)
        "pti=on"

        # Randomize kernel stack offset
        "randomize_kstack_offset=on"

        # Disable vsyscalls (replace with vDSO)
        "vsyscall=none"

        # Disable debugfs (prevents sensitive info leakage)
        "debugfs=off"

        # Panic on oops (prevent exploitation of kernel bugs)
        "oops=panic"

        # Enforce module signature verification
        "module.sig_enforce=1"

        # Enable kernel lockdown (prevent privilege escalation)
        "lockdown=confidentiality"
    ];

    # ============================================================================
    # SECTION 4: KERNEL MODULE BLOCKING
    # ============================================================================
    # WARN: Disable unused/unsafe kernel modules - may break some hardware
    boot.extraModprobeConfig = ''
        # Disable FireWire (known attack vector)
        install firewire-core /bin/false
        install firewire_core /bin/false
        install firewire-ohci /bin/false
        install firewire_ohci /bin/false
        install firewire_sbp2 /bin/false
        install firewire-sbp2 /bin/false
        install firewire-net /bin/false

        # Disable Thunderbolt (DMA attack vector)
        install thunderbolt /bin/false

        # Disable IEEE 1394 (FireWire)
        install ohci1394 /bin/false
        install sbp2 /bin/false
        install dv1394 /bin/false
        install raw1394 /bin/false
        install video1394 /bin/false

        # Disable USB storage (prevent unauthorized data access)
        install usb-storage /bin/false
    '';

    # INFO: Block dangerous kernel modules
    boot.blacklistedKernelModules = [
        # Rare/unused network protocols (attack surface reduction)
        "dccp" "sctp" "rds" "tipc" "n-hdlc" "ax25" "netrom"
        "x25" "rose" "decnet" "econet" "af_802154" "ipx" "appletalk"
        "psnap" "p8023" "p8022" "can" "atm"

        # Rare filesystems (attack surface reduction)
        "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "udf"
    ];

    # ============================================================================
    # SECTION 5: SYSTEMD SERVICE HARDENING
    # ============================================================================
    # INFO: Disable core dumps at systemd level
    systemd.coredump.enable = false;

    # INFO: Disable core dumps at PAM level
    security.pam.loginLimits = [{
        domain = "*";
        type = "-";
        item = "core";
        value = "0";
    }];

    # INFO: Harden critical system services with security profiles
    systemd.services = {
        bluetooth.serviceConfig = {
            ProtectKernelTunables = lib.mkDefault true;
            ProtectKernelModules = lib.mkDefault true;
            ProtectKernelLogs = lib.mkDefault true;
            ProtectHostname = true;
            ProtectControlGroups = true;
            ProtectProc = "invisible";
            SystemCallFilter = [
                "~@obsolete" "~@cpu-emulation" "~@swap"
                "~@reboot" "~@mount"
            ];
            SystemCallArchitectures = "native";
        };

        NetworkManager.serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            ProtectHostname = false;
            RestrictSUIDSGID = true;
            RemoveIPC = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
        };

        "NetworkManager-dispatcher".serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            RestrictSUIDSGID = true;
            RemoveIPC = true;
            NoNewPrivileges = true;
        };

        display-manager.serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
        };

        nix-daemon.serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            RestrictSUIDSGID = true;
            RemoveIPC = true;
            NoNewPrivileges = true;
        };

        docker.serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
        };

        libvirtd.serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
        };

        wpa_supplicant.serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            RestrictSUIDSGID = true;
            RemoveIPC = true;
            NoNewPrivileges = true;
        };

        nscd.serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
        };

        "dbus-broker".serviceConfig = {
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
        };
    };

    # ============================================================================
    # SECTION 6: TELEMETRY DISABLING
    # ============================================================================
    # INFO: Disable services that may leak privacy data
    services = {
        dbus.implementation = "broker";
        logrotate.enable = true;
        journald = {
            # Store logs in memory (prevents disk-based forensics)
            storage = "volatile";
            upload.enable = false;
            extraConfig = ''
                SystemMaxUse=500M
                SystemMaxFileSize=50M
            '';
        };

        # Disable telemetry services
        avahi.enable = false;
        geoclue2.enable = false;
        udisks2.enable = false;
        accounts-daemon.enable = false;
    };

    # INFO: Disable modem manager (WWAN/3G/4G not used)
    networking.modemmanager.enable = false;

    # INFO: Disable automatic system upgrades (manual control)
    system.autoUpgrade.enable = false;


    # ============================================================================
    # SECTION 7: SECURITY BANNER
    # ============================================================================
    # INFO: Login banner for legal warning
    environment.etc."issue".text = ''
        *****************************************************************************
        *        WARNING: Authorized Access Only!                                   *
        *        This system is restricted to authorized users only.                 *
        *        All activities on this system are monitored and recorded.           *
        *        Unauthorized access is strictly prohibited and will be prosecuted.  *
        *****************************************************************************
    '';


    # ============================================================================
    # SECTION 8: PASSWORD POLICY
    # ============================================================================
    # INFO: Disable GNOME keyring (security preference)
    security.pam = {
        services = {
            login.enableGnomeKeyring = lib.mkForce false;
        };
    };

    # INFO: Password aging and quality settings
    security.loginDefs.settings = {
        FAIL_DELAY = "3";
        LOGIN_RETRIES = "3";
        LOGIN_TIMEOUT = "30";
        PASS_MAX_DAYS = "90";
        PASS_MIN_DAYS = "7";
        PASS_WARN_AGE = "7";
        PASS_MIN_LEN = "12";
        ENCRYPT_METHOD = "SHA512";

        # Enforce SHA512 hashing rounds
        MD5_CRYPT_ENAB = "false";
        SHA_CRYPT_MIN_ROUNDS = "10000";
        SHA_CRYPT_MAX_ROUNDS = "10000";
    };

    # INFO: Restrict default umask for new files
    systemd.services."systemd-logind".serviceConfig.UMask = "0027";


    # ============================================================================
    # SECTION 9: NETWORK PRIVACY
    # ============================================================================
    # INFO: Enable WiFi MAC address randomization (privacy)
    networking.networkmanager.wifi.macAddress = "random";


    # ============================================================================
    # SECTION 10: KERNEL MODULE LOCKING
    # ============================================================================
    # FIX: Lock kernel module loading after boot - addresses Lynis warning about kernel.modules_disabled
    systemd.services."lock-kernel-modules" = {
        description = "Lock kernel module loading";
        after = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.procps}/bin/sysctl -w kernel.modules_disabled=1";
        };
    };


    # ============================================================================
    # SECTION 11: FILE INTEGRITY MONITORING (AIDE)
    # ============================================================================
    # INFO: AIDE configuration for AIDE 0.19+
    environment.etc."aide.conf".text = ''
        database_in=file:/var/lib/aide/aide.db.gz
        database_out=file:/var/lib/aide/aide.db.new.gz
        gzip_dbout=yes
        report_url=stdout

        # Monitor critical system directories
        /bin p+i+u+g+n+acl+xattrs+sha512
        /sbin p+i+u+g+n+acl+xattrs+sha512
        /usr/bin p+i+u+g+n+acl+xattrs+sha512
        /usr/sbin p+i+u+g+n+acl+xattrs+sha512
        /lib p+i+u+g+n+acl+xattrs+sha512
        /usr/lib p+i+u+g+n+acl+xattrs+sha512
        /var/lib p+i+u+g+n+acl+xattrs+sha512
        /etc p+i+u+g+n+acl+xattrs+sha512
    '';

    # INFO: Create log directories
    systemd.tmpfiles.rules = [
        "d /var/log/aide 0750 root root -"
        "d /var/lib/aide 0750 root root -"
        "d /var/log/clamav 0750 root root -"
    ];

    # INFO: Initialize AIDE database on first boot
    systemd.services."aide-init" = {
        description = "Initialize AIDE database if not present";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = pkgs.writeShellScript "aide-init.sh" ''
                #!/bin/bash
                set -e

                AIDE_DB="/var/lib/aide/aide.db.gz"
                
                # Only initialize if database doesn't exist
                if [ ! -f "$AIDE_DB" ]; then
                    echo "Initializing AIDE database..."
                    /run/current-system/sw/bin/aide --init
                    
                    if [ -f "/var/lib/aide/aide.db.new.gz" ]; then
                        cp /var/lib/aide/aide.db.new.gz "$AIDE_DB"
                        echo "AIDE database initialized successfully"
                    fi
                else
                    echo "AIDE database already exists, skipping initialization"
                fi
            '';
        };
    };


    # ============================================================================
    # SECTION 12: SECURITY PACKAGES
    # ============================================================================
    environment.systemPackages = [
        pkgs.lynis
        pkgs.clamav
        pkgs.aide
        pkgs.audit
        pkgs.lnav
    ];


    # ============================================================================
    # SECTION 13: CLAMAV ANTIVIRUS SCANNING
    # ============================================================================
    # INFO: Daily ClamAV scan service
    systemd.services.clamav-daily-scan = {
        description = "Daily ClamAV virus scan";
        after = [ "network.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            User = "root";
            StandardOutput = "journal";
            StandardError = "journal";
            ExecStart = pkgs.writeShellScript "clamav-daily-scan.sh" ''
                #!/bin/bash
                set -e

                SCAN_DIRS="/home /tmp /var /srv /nix/store"
                LOG_FILE="/var/log/clamav/scan.log"

                mkdir -p "$(dirname "$LOG_FILE")"

                echo "=== ClamAV Scan $(date) ===" >> "$LOG_FILE"

                # Scan directories and detect PUA (potentially unwanted apps)
                clamscan --recursive --detect-pua=yes \
                    --exclude-dir="/proc" --exclude-dir="/sys" --exclude-dir="/dev" \
                    --log="$LOG_FILE" $SCAN_DIRS 2>&1 | tail -50 >> "$LOG_FILE"

                # Check for threats
                THREATS=$(grep -c "FOUND" "$LOG_FILE" 2>/dev/null || echo "0")

                if [ "$THREATS" -gt 0 ]; then
                    THREAT_SUMMARY=$(grep "FOUND" "$LOG_FILE" | head -5 | tr '\n' ' ')

                    # Send critical notification if threats found
                    /run/current-system/sw/bin/notify-send -u critical -t 10000 \
                        "ClamAV Alert" "Threats detected: $THREAT_SUMMARY"

                    echo "ALERT: $THREATS threats detected at $(date)" >> "$LOG_FILE"
                else
                    echo "Scan completed - No threats found at $(date)" >> "$LOG_FILE"
                fi

                # Cleanup old logs (keep 7 days)
                find /var/log/clamav -name "scan.log.*" -mtime +7 -delete 2>/dev/null || true
            '';
        };
    };

    # INFO: Timer for daily scan at 3am
    systemd.timers.clamav-daily-scan = {
        description = "Daily ClamAV virus scan timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnCalendar = "*-*-* 03:00:00";
            Persistent = true;
        };
    };

    # INFO: Boot-time scan for early threat detection
    systemd.services."clamav-boot-scan" = {
        description = "ClamAV scan on boot";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            User = "root";
            StandardOutput = "journal";
            StandardError = "journal";
            ExecStart = pkgs.writeShellScript "clamav-boot-scan.sh" ''
                #!/bin/bash
                set -e

                SCAN_DIRS="/home /tmp /var"
                LOG_FILE="/var/log/clamav/scan.log"

                mkdir -p "$(dirname "$LOG_FILE")"

                echo "=== ClamAV Boot Scan $(date) ===" >> "$LOG_FILE"

                clamscan --recursive --detect-pua=yes --log="$LOG_FILE" $SCAN_DIRS 2>&1 | tail -30 >> "$LOG_FILE"

                THREATS=$(grep -c "FOUND" "$LOG_FILE" 2>/dev/null || echo "0")

                if [ "$THREATS" -gt 0 ]; then
                    THREAT_SUMMARY=$(grep "FOUND" "$LOG_FILE" | head -5 | tr '\n' ' ')
                    /run/current-system/sw/bin/notify-send -u critical -t 10000 \
                        "ClamAV Alert (Boot)" "Threats detected: $THREAT_SUMMARY"
                fi
            '';
        };
    };
}