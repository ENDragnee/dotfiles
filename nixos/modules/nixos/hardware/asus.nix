{ pkgs, ... }:
{
  services.asusd.enable = true;
  services.supergfxd.enable = true;
  environment.systemPackages = [ pkgs.asusctl ];
}
