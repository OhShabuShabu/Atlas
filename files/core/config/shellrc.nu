# =============================================================================
    # Nushell Configuration (like .bashrc)
    # =============================================================================
    # This file is sourced by Nushell on startup

    #$env.PATH = ($env.PATH | append "$HOME/.local/bin")

    # INFO: ALIASES
    alias motivate = python3 /home/yusa/Atlas/files/bin/python/motivate

    # INFO: Security tool aliases
    alias logs = ^sudo sh -c "ls -1rt /var/log/*.log | fzf --height=40% --layout=reverse --ansi | xargs -r lnav"
    alias security-logs = ^sudo sh -c "ls -1rt /var/log/lynis.log /var/log/audit/audit.log /var/log/clamav/*.log 2>/dev/null | fzf --height=40% --layout=reverse --ansi | xargs -r lnav"
    alias lynis-scan = ^sudo lynis audit system --quick
    alias aide-check = ^sudo aide --check

    # cd wrapper that falls back to zoxide
    alias __cd = cd
    alias cd = __cd

    def --env --wrapped __my_cd [...path: string] {
        let path_str = ($path | str join " ")
        
        if $path_str == "" {
            cd ~
        } else if $path_str == "-" {
            cd -
        } else if ($path_str | path expand | path type) == "dir" {
            cd $path_str
        } else {
            let result = (zoxide query -- $path_str | str trim)
            if $result == "" {
                error make {msg: $"directory not found: ($path_str)"}
            } else {
                cd $result
            }
        }
    }

    alias cd = __my_cd

    motivate