{ pkgs, ... }:
{

  users.users.end = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "power"
      "docker"
      "libvirtd"
      "plocate"
      "kvm"
    ];
    shell = pkgs.fish;
  };
}
