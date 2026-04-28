{ config, pkgs, lib, ... }:
{
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "yusa" ];
  users.users.yusa.extraGroups = [ "libvirtd" ];

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.podman = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [ 
    distrobox dnsmasq
    docker docker-compose
  ];


}
