{ pkgs, ... }:
{
  services.printing.enable = true;
  services.asusd.enable = true;
  services.supergfxd.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.dbus.enable = true;
  services.libinput.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.blueman.enable = true;
  services.fstrim.enable = true;
  services.openssh.enable = true;
  services.dbus.packages = [ pkgs.dconf ];
}
