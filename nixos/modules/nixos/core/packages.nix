{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.claude-desktop.enable = true;
  programs.dconf.enable = true;
  programs.seahorse.enable = true;
  programs.kdeconnect.enable = true;
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

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    libmtp
    m17n_db
    adwaita-icon-theme
  ];
}
