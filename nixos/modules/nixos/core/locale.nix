{ pkgs, ... }:
{
  time.timeZone = "Africa/Addis_Ababa";

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      m17n
    ];
  };
}
