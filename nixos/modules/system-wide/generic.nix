{ lib, ... }:
{
  time.timeZone = "Africa/Addis_Ababa";
  # security.wrappers.bwrap.setuid = lib.mkForce false;

  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
  };
}
