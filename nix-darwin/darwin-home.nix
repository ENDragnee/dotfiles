{
  config,
  lib,
  ...
}:
{
  imports = [
    # Import your specific modules for git, fish, and neovim
    ./modules/home-manager/fish.nix
    ./modules/home-manager/git.nix
    ../nixos/modules/home/editor/nvchad # shared with NixOS; Lua in ../nvim/lua/custom
    ./modules/home-manager/packages.nix
  ];

  home.username = "mastwal";
  home.homeDirectory = "/Users/mastwal";

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  dotfiles.nvchad = {
    java.enable = true;
    prose.enable = true;
    latex.enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
