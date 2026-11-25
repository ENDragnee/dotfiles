{ ... }:
{
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      # SSH (22) is opened by services.openssh. For a dev server on the LAN, open
      # a port until the next reboot/rebuild with: sudo nixos-firewall-tool open tcp 4321
      allowedTCPPorts = [
        22000 # Syncthing sync
      ];
      allowedUDPPorts = [
        21027 # Syncthing discovery
        22000 # Syncthing QUIC
      ];
      trustedInterfaces = [ "virbr0" ];
    };
  };
}
