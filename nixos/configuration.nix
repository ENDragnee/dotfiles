# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot = {
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    plymouth = {
      enable = true;
      theme = "darth_vader";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "darth_vader" ];
        })
      ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Add this line
  };
  services.avahi = {
    enable = true;
    hostName = "vds-host";
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
  nix.settings = {
    substituters = [ "https://niri.cachix.org" ];
    trusted-public-keys = [ "niri.cachix.org-1:Wv0Om607ZpInqlal9Q/3uH5N8vXn9I3m0kS89n0I3G0=" ];
  };
  services.fstrim.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "iced"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Addis_Ababa";
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    # Use the open-source kernel module (Good for TUF laptops with RTX 20+ cards)
    open = true;

    prime = {
      # Offload mode is usually better for laptops
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      amdgpuBusId = "pci:06:00:0"; # Change this to your actual AMD ID
      nvidiaBusId = "pci:01:00:0"; # Change this to your actual NVIDIA ID
    };
    powerManagement.enable = true;
  };

  # fileSystems."/mnt/arch-home" = {
  #   device = "/dev/disk/by-uuid/fbce7138-5767-4deb-813a-13a63065340e";
  #   fsType = "ext4";
  #   options = [
  #     "users" # Allows any user to mount and unmount
  #     "nofail" # Prevent system from failing if this drive doesn't mount
  #     "x-gvfs-show"
  #   ];
  # };

  # fileSystems."/mnt/ice" = {
  #   device = "/dev/disk/by-uuid/09b98b66-2799-4ea7-a77d-830fe3341bd1";
  #   fsType = "ext4";
  #   options = [
  #     "users" # Allows any user to mount and unmount
  #     "nofail" # Prevent system from failing if this drive doesn't mount
  #     "x-gvfs-show"
  #   ];
  # };

  # fileSystems."/mnt/arch-root" = {
  #   device = "/dev/disk/by-uuid/1dd01183-da7b-44cc-ba8b-691b7aa995f1";
  #   fsType = "ext4";
  #   options = [
  #     "users" # Allows any user to mount and unmount
  #     "nofail" # Prevent system from failing if this drive doesn't mount
  #     "x-gvfs-show"
  #   ];
  # };
  # swapDevices = [
  #   {
  #     device = "/dev/disk/by-uuid/4eebb7e2-67c1-4e47-8f2c-7342ed054296";
  #   }
  # ];

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.asusd = {
    enable = true;
  };
  services.supergfxd.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.dbus.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.languagetool.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.end = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "power"
      "docker"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    shell = pkgs.fish;
  };

  # programs.firefox.enable = true;
  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  programs.seahorse.enable = true;
  programs.kdeconnect.enable = true;
  programs.niri = {
    enable = true;
  };
  programs.fish.enable = true;
  # programs.uwsm.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries here if programs crash
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    neovim
    asusctl
    nvtopPackages.full
    dnsmasq
    adwaita-icon-theme
    glib
    libmtp
    nettools
    seahorse
    virt-viewer
  ];

  virtualisation.docker.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
      };
    };
  };
  services.dbus.packages = [ pkgs.dconf ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    22000
  ];
  networking.firewall.trustedInterfaces = [ "virbr0" ];
  networking.firewall.allowedUDPPorts = [
    21027
    22000
  ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
