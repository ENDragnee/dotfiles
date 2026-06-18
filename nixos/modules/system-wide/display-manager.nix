{ pkgs, ... }:
let
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    settings = {
      Theme = {
        Current = "sddm-astronaut-theme";
        CursorTheme = "Adwaita";
        CursorSize = 24;
      };
    };
    extraPackages = with pkgs; [
      custom-sddm-astronaut
      bibata-cursors
    ];
  };
}
