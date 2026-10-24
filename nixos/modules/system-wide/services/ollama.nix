{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    # package = pkgs.ollama-cuda;
    package = pkgs.ollama-vulkan;
    # acceleration = "cuda";
    host = "127.0.0.1";
    openFirewall = false;
    environmentVariables = {
      # OLLAMA_MODELS = "/home/end/.ollama/models";
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
    };
  };
}
