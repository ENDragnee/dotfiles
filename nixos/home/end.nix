{ config, lib, ... }:
let
  TERM = "kitty";
in
{
  imports = [ ../modules/home ];

  home.username = "end";
  home.homeDirectory = "/home/end";
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    TERMINAL = TERM;
    TERM_PROGRAM = TERM;
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = lib.mkForce "gtk3";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.age/key.txt";
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    EDITOR = "nvim";
  };
  home.stateVersion = "25.11";
}
