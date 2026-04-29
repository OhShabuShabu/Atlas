{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    bun
    opencode
    claude-code
    neovim
    vscode
  ];
  home.file = {
    ".config/nvim".source = ./nvim;
  };

}
