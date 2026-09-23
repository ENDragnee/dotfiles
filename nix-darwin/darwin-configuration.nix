{ pkgs, ... }:

{
  # Necessary for using flakes on nix-darwin
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;
  nix.enable = false;
# Enable fish as a valid system shell
  programs.fish.enable = true;
  users.users.mastwal = {
    name = "mastwal";
    home = "/Users/mastwal";
    shell = pkgs.fish;
  };
  # Used for backwards compatibility, please read the changelog before changing
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Configure Mac underlying hostname
  networking.hostName = "mastwal-mac";
  networking.computerName = "mastwal-mac";

  nixpkgs.hostPlatform = "aarch64-darwin";
}
