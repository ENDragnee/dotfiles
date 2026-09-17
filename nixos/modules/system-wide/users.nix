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
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.fish;
  };
}
