{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/system-wide/init.nix
  ];

  # First NixOS version installed on this machine; keeps stateful data compatible.
  # It does NOT pick the nixpkgs version. Do not change it after install, see
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "25.11";
}
