{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # Essential system packages available to all users via nix-darwin
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    neovim
    curl
    jq
    ripgrep
  ];

  # Fonts can also be declared system-wide if desired
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
