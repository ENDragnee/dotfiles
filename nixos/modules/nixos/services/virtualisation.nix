{ pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # Rootful on purpose: existing containers/images/volumes live in /var/lib/docker.
  # Note the docker group (users.nix) is root-equivalent.
  virtualisation.docker.enable = true;
  environment.systemPackages = [ pkgs.virt-viewer ];
}
