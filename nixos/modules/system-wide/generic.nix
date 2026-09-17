{ lib, ... }:
{
  time.timeZone = "Africa/Addis_Ababa";
  # security.wrappers.bwrap.setuid = lib.mkForce false;
  programs.nix-ld.enable = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
  };

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.12"
    "ventoy-gtk3-1.1.12"
    "ventoy-qt5-1.1.12"
  ];
}
