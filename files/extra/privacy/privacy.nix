{ config, pkgs, inputs, ... }:

{
    environment.systemPackages = with pkgs; [
        mullvad-vpn
        mullvad
        mullvad-browser
    ];
    services.mullvad-vpn.enable = true;
}
