{ pkgs, ... }:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        # Keep /boot (1 GiB vfat) from filling up with old kernels and initrds.
        configurationLimit = 10;
      };
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
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    # No menu for a fast boot; hold Space while booting to pick an older generation.
    loader.timeout = 0;
  };
}
