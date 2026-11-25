{ ... }:
{
  imports = [
    ./shell/direnv.nix
    ./shell/fish.nix
    ./shell/git.nix

    ./desktop/dms.nix
    ./desktop/flameshot.nix
    ./desktop/hyprland
    ./desktop/niri
    ./desktop/theme.nix

    ./apps/alacritty.nix
    ./apps/packages.nix
    ./apps/spicetify.nix
    ./apps/syncthing.nix

    ./editor
  ];
}
