{ inputs, pkgs, ... }:
{
  programs.dank-material-shell = {
    enable = true;
    dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;

    clipboardSettings = {
      maxHistory = 1000;
      maxEntrySize = 5242880;
      autoClearDays = 1;
      clearAtStartup = false;
      disabled = false;
      disableHistory = false;
      disablePersist = true;
    };
    niri = {
      enableKeybinds = false;
      includes = {
        enable = true;
        override = true;
        # originalFileName = "base";
        filesToInclude = [
          "../custom"
          "alttab"
          "animations"
          "binds"
          "colors"
          "cursor"
          "layout"
          "outputs"
          "windowrules"
          "wpblur"
        ];
      };
    };
  };
}
