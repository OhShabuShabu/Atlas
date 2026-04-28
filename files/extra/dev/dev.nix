{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    bun
    opencode
    claude-code
    neovim
  ];
  home.file = {
    ".config/nvim".source = ./nvim;
  };

}
