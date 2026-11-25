{ inputs, lib, ... }:
{
  imports = [ inputs.niri.homeModules.niri ];

  programs.niri.settings = {
    binds = lib.mkForce { };
    layout.border.enable = true;
  };

  xdg.configFile."niri/custom.kdl".source = ./my-config.kdl;
}
