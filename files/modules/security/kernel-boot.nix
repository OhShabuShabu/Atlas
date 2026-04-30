{ config, pkgs, lib, ... }:

# INFO: ============================================================================
# INFO: KERNEL BOOT PARAMETERS & MODULE BLOCKING
# INFO: ============================================================================
# INFO: Kernel command-line hardening and module security
# NOTE: Boot parameters use kernelParams, modules use modprobeConfig
# WARN: Some blocked modules may break hardware - review before deploying
# NOTE: Updated for NixOS 25.x/2026 security standards

let
  # INFO: Kernel boot parameters for security
  # NOTE: Enhanced with latest hardened profile recommendations
  bootParams = [
    "slab_nomerge"                       # INFO: Disable slab merging
    "init_on_alloc=1"                   # INFO: Zero memory on alloc
    "init_on_free=1"                    # INFO: Zero memory on free
    "page_poison=1"                      # FIX: Poison free pages (from hardened profile)
    "page_alloc.shuffle=1"              # INFO: Randomize page allocator
    "pti=on"                             # INFO: Page Table Isolation
    "randomize_kstack_offset=on"         # INFO: Randomize kernel stack
    "vsyscall=none"                     # INFO: Disable vsyscalls
    "debugfs=off"                        # INFO: Disable debugfs
    "oops=panic"                        # INFO: Panic on oops
    "module.sig_enforce=1"               # INFO: Enforce module signatures
    "lockdown=confidentiality"          # INFO: Kernel lockdown
    # FIX: Additional boot params from hardened profile
    "slab_merge=off"                    # INFO: Explicitly disable slab merging
  ];

  # INFO: Modules to block via modprobe (returns /bin/false)
  # NOTE: Hardware that needs these modules should add them to boot.kernelModules
  blockedModules = ''
    install firewire-core /bin/false
    install firewire_core /bin/false
    install firewire-ohci /bin/false
    install firewire_ohci /bin/false
    install firewire_sbp2 /bin/false
    install firewire-sbp2 /bin/false
    install firewire-net /bin/false
    install thunderbolt /bin/false
    install ohci1394 /bin/false
    install sbp2 /bin/false
    install dv1394 /bin/false
    install raw1394 /bin/false
    install video1394 /bin/false
    # WARN: usb-storage blocked by default - add to boot.kernelModules if needed
    install usb-storage /bin/false
  '';

  # INFO: Blacklisted kernel modules (completely disabled)
  # NOTE: Enhanced with additional modules from hardened profile
  blacklistedModules = [
    # INFO: Rare/unused network protocols
    "dccp" "sctp" "rds" "tipc" "n-hdlc" "ax25" "netrom"
    "x25" "rose" "decnet" "econet" "af_802154" "ipx" "appletalk"
    "psnap" "p8023" "p8022" "can" "atm"
    # INFO: Rare filesystems (from hardened profile)
    "cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "udf"
    "adfs" "affs" "bfs" "befs" "efs" "erofs" "exofs"
    "minix" "nilfs2" "ntfs" "omfs" "qnx4" "qnx6" "sysv" "ufs"
    # INFO: Additional rare filesystems
    "hpfs" "squashfs" "romfs"
  ];
in

{
  # INFO: Apply kernel boot parameters
  boot.kernelParams = bootParams;

  # INFO: Apply module blocking config
  boot.extraModprobeConfig = blockedModules;

  # INFO: Blacklist dangerous modules
  boot.blacklistedKernelModules = blacklistedModules;

  # NOTE: Lock kernel module loading is now handled by security.lockKernelModules
  #       in configuration.nix - keeping this as backup
  # WARN: This service may conflict with security.lockKernelModules
  # systemd.services."lock-kernel-modules".enable = false;
}