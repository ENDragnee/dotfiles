{ ... }:
{
  hardware.bluetooth.enable = true;
  networking = {
    hostName = "iced";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        22000
        4321
        8006
      ];
      allowedUDPPorts = [
        21027
        22000
      ];
      trustedInterfaces = [ "virbr0" ];
    };
  };
}
