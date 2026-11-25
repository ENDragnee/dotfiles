{ ... }:
{
  # Hyprland itself is not enabled (see modules/nixos/desktop/niri.nix).
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
}
