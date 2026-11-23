{ pkgs, ... }:
let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
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
    # --- Core & Recovery ---
    vim
    wget
    git
    asusctl
    libmtp
    m17n_db
    virt-viewer
    # neovim # redundant; managed by Home Manager (nvchad)
    # seahorse # already installed by programs.seahorse.enable
    # dnsmasq # already pulled in internally by virtualisation.libvirtd
    # nettools # legacy (ifconfig/netstat); NixOS includes iproute2 (ip/ss) by default
    # glib # library; rarely needed in systemPackages unless calling gio/gsettings directly

    # --- SDDM & System Themes ---
    custom-sddm-astronaut
    kdePackages.qtmultimedia # required by sddm-astronaut theme
    adwaita-icon-theme
    bibata-cursors
  ];
}
