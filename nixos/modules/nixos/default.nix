{ ... }:
{
  imports = [
    ./core/boot.nix
    ./core/locale.nix
    ./core/networking.nix
    ./core/nix.nix
    ./core/packages.nix
    ./core/users.nix

    ./hardware/asus.nix
    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/nvidia.nix

    ./desktop/niri.nix
    ./desktop/portals.nix
    ./desktop/sddm.nix
    ./desktop/services.nix

    ./services/avahi.nix
    ./services/btrfs.nix
    ./services/flatpak.nix
    ./services/locate.nix
    # ./services/net-ban.nix # local only, gitignored
    ./services/ollama.nix
    ./services/ssh.nix
    ./services/virtualisation.nix
  ];
}
