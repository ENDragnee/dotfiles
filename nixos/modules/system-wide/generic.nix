{ lib, ... }:
{
  time.timeZone = "Africa/Addis_Ababa";
  # security.wrappers.bwrap.setuid = lib.mkForce false;
  programs.nix-ld.enable = true;

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
  };
}
