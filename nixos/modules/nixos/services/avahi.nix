{ ... }:
{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    settings = {
      server = {
        use-ipv4 = true;
        use-ipv6 = true;
        host-name = "waldo"; # replace with whatever you had in hostName
      };
      publish = {
        disable-publishing = false;
        publish-addresses = true;
        publish-workstation = true;
      };
    };
  };
}
