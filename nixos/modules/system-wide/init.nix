{ ... }: {
  imports = [
    ./audio.nix
    ./avahi.nix
    ./boot.nix
    ./display-manager.nix
    ./flatpak.nix
    ./generic.nix
    ./i18n.nix
    ./networking.nix
    # ./net-ban.nix
    ./nix-settings.nix
    ./nvidia.nix
    ./packages.nix
    ./users.nix
    ./xdg.nix

    ./services/generic.nix
    ./services/brtfs.nix
    ./services/ollama.nix
    ./services/locate.nix
  ];
}
