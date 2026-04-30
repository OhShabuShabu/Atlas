{ pkgs, lib, ... }:

# INFO: ============================================================================
# INFO: AUDITD CONFIGURATION - System Audit Logging
# INFO: ============================================================================
# INFO: Auditd monitors system calls and logs security events for compliance
# FIX: Configured with proper log file location and audit rules (ACCT-9634)

{
  # FIX: auditd is already enabled in configuration.nix, this adds rules and logging config
  
  # FIX: Create audit log directory with proper permissions (ACCT-9634)
  systemd.tmpfiles.rules = [
    "d /var/log/audit 0750 root root -"
    "f /var/log/audit/audit.log 0640 root root -"
  ];

  # FIX: Configure auditd daemon with proper logging (ACCT-9634)
  # NOTE: auditd.conf is typically configured via services.auditd but NixOS 
  #       handles it through the security.auditd module
  environment.etc."audit/audit.rules".text = ''
    # Remove any existing rules
    -D
    
    # Buffer Size
    -b 2048
    
    # Failure Mode - panic on critical errors
    -f 1

    # FIX: Monitor system call events for security
    # NOTE: These rules track important security-relevant syscalls
    
    # Monitor authentication changes
    -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change
    -a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time_change
    -a always,exit -F arch=b64 -S clock_settime -k time_change
    -a always,exit -F arch=b32 -S clock_settime -k time_change
    -w /etc/localtime -p wa -k time_change

    # Monitor user/group changes
    -w /etc/group -p wa -k identity
    -w /etc/passwd -p wa -k identity
    -w /etc/gshadow -p wa -k identity
    -w /etc/shadow -p wa -k identity
    -w /etc/security/opasswd -p wa -k identity

    # Monitor network changes
    -a always,exit -F arch=b64 -S sethostname -S setdomainname -k network_modifications
    -a always,exit -F arch=b32 -S sethostname -S setdomainname -k network_modifications
    -w /etc/hostname -p wa -k network_modifications
    -w /etc/hosts -p wa -k network_modifications
    -w /etc/network -p wa -k network_modifications

    # Monitor login/logout events
    -w /var/log/faillog -p wa -k logins
    -w /var/log/lastlog -p wa -k logins
    -w /var/log/tallylog -p wa -k logins

    # Monitor sudoers changes
    -w /etc/sudoers -p wa -k scope
    -w /etc/sudoers.d/ -p wa -k scope

    # Monitor kernel module changes
    -w /sbin/insmod -p x -k modules
    -w /sbin/rmmod -p x -k modules
    -w /sbin/modprobe -p x -k modules
    -a always,exit -F arch=b64 -S init_module,delete_module -k modules

    # Monitor permissions changes
    -a always,exit -F arch=b64 -S chmod -F auid>=1000 -F auid!=-1 -k perm_mod
    -a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=-1 -k perm_mod
    -a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=-1 -k perm_mod
    -a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod

    # Monitor unauthorized access attempts
    -a always,exit -F arch=b64 -S open,openat -F exit=-EACCES -F auid>=1000 -F auid!=-1 -k access
    -a always,exit -F arch=b64 -S open,openat -F exit=-EPERM -F auid>=1000 -F auid!=-1 -k access

    # Make the configuration immutable - prevent audit rule tampering
    -e 2
  '';

  # FIX: auditd daemon configuration is handled via audit.rules
  # NOTE: audit.conf would need to be created separately if needed
  # For now, audit rules are sufficient for compliance (ACCT-9634)

  # INFO: Additional security packages for audit monitoring
  environment.systemPackages = with pkgs; [
    # INFO: audit tools for log analysis
    audit  # INFO: Already included in base security module
  ];

  # FIX: Shell alias for audit log viewing
  environment.etc."profile.d/92-audit.sh".text = ''
    # INFO: View recent audit logs
    alias audit-tail='sudo tail -f /var/log/audit/audit.log'
    alias audit-search='sudo ausearch'
    alias audit-report='sudo aureport'
  '';
}
