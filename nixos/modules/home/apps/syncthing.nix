{ ... }:
{
  # Runs as a user service with the existing ~/.local/state/syncthing config;
  # firewall ports are in modules/nixos/core/networking.nix.
  services.syncthing.enable = true;
}
