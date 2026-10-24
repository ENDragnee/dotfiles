{ ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # services.xserver.videoDrivers = [ "nvidia" ]; # Crucial for NixOS to pull CUDA packages

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      amdgpuBusId = "pci:06:00:0";
      nvidiaBusId = "pci:01:00:0";
    };
    powerManagement.enable = true;
  };
}
