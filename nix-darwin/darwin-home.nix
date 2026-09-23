{
  config,
  lib,
  nix4nvchad,
  ...
}:
{
  imports = [
    nix4nvchad.homeManagerModules.default

    # Import your specific modules for git, fish, and neovim
    ./modules/home-manager/fish.nix
    ./modules/home-manager/git.nix
    ./desktop/configs/nvim/nvchad.nix # Assuming this is your niched.nix renamed or included
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
