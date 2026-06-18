{ pkgs, ... }:
let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  # programs.firefox.enable = true;
  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  programs.seahorse.enable = true;
  programs.kdeconnect.enable = true;
  programs.niri.enable = true;
  programs.mangowc.enable = true;
  programs.hyprland.enable = true;
  programs.labwc.enable = true;
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    neovim
    asusctl
    dnsmasq
    adwaita-icon-theme
    glib
    libmtp
    nettools
    seahorse
    virt-viewer
    kdePackages.qtmultimedia
    m17n_db
    custom-sddm-astronaut
    bibata-cursors
  ];
}
