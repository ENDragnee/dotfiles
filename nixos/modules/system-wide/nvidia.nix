{ ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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
