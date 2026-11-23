{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.claude-desktop.enable = true;
  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  programs.seahorse.enable = true;
  programs.kdeconnect.enable = true;
  programs.niri.enable = true;
  # programs.mango.enable = true;
  # programs.hyprland.enable = true;
  # programs.labwc.enable = true;
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
    asusctl
    libmtp
    m17n_db
    virt-viewer
    adwaita-icon-theme
  ];
}
