{ pkgs, ... }:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    plymouth = {
      enable = true;
      theme = "darth_vader";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "darth_vader" ];
        })
      ];
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    loader.timeout = 0;
  };
}
