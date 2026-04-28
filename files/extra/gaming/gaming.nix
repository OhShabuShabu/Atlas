{ config, pkgs, inputs, ... }:

{
    environment.systemPackages = with pkgs; [
        steam
        steamcmd
    ];
    nixpkgs.overlays = [ inputs.millennium.overlays.default ]; # Steam support with Millennium


    hardware.graphics = {
        enable32Bit = true; # Required for Steam/CS2
    };

    programs.steam = {
        enable = true;
        package = pkgs.millennium-steam;
    };
    hardware.steam-hardware.enable = true;
}