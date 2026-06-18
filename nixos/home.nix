{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
    inputs.nix4nvchad.homeManagerModule
    inputs.spicetify-nix.homeManagerModules.default

    #modules
    ./modules/home-manager/alacritty.nix
    ./modules/home-manager/direnv.nix
    ./modules/home-manager/dms.nix
    ./modules/home-manager/fish.nix
    ./modules/home-manager/git.nix
    ./modules/home-manager/packages.nix
    ./modules/home-manager/spicetify.nix
    ./modules/home-manager/theme.nix

    #dekstop configs
    ./desktop/applications/neovim.nix
    ./desktop/configs/flameshot/config.nix
    ./desktop/configs/nvim/nvchad.nix
    ./desktop/configs/xresources.nix
  ];
  home.username = "end";
  home.homeDirectory = "/home/end";
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
  ];

  fonts.fontconfig.enable = true;

  programs.niri.settings.binds = lib.mkForce { };
  xdg.configFile."niri/custom.kdl".source = ./desktop/configs/niri/my-config.kdl;
  xdg.configFile."hypr/hyprland.lua".source = ./desktop/configs/hypr/hyprland.lua;

  home.sessionVariables = {
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    # TERM = "xterm-256color";
    TERMINAL = "alacritty";
    TERM_PROGRAM = "alacritty";
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
