{ config, pkgs, ... }:

{
  xdg.configFile."flatpak/overrides/default".text = ''
    [Context]
    gtk_theme=Adwaita-dark
  '';
  home.packages = with pkgs; [
    flatpak
  ];
  home.file."${config.xdg.dataHome}/flatpak/repo/flathub.flatpakrepo".source = pkgs.fetchurl {
    url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    sha256 = "0fm0zvlf4fipqfhazx3jdx1d8g0mvbpky1rh6riy3nb11qjxsw9k";
  };
}
