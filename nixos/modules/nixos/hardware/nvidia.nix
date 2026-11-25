{ ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # lspci shows hex (01:00.0, 06:00.0); NixOS wants decimal "PCI:bus:device:function".
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement = {
      enable = true;
      finegrained = true; # RTD3: power off the dGPU when idle (Turing+, offload only)
    };
  };
}
