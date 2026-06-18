{ ... }:
{
  services.avahi = {
    enable = false;
    hostName = "end";
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
    openFirewall = true;
  };
}
