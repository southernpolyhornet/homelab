# NVIDIA GPU and CUDA support module
# This module configures NVIDIA proprietary drivers and CUDA toolkit
{ config, pkgs, lib, ... }:

{
  # Enable unfree packages (required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # NVIDIA hardware configuration
  hardware.nvidia = {
    # Enable modesetting for better compatibility
    # This works with both X server (for Steam) and headless (for CUDA/Docker)
    modesetting.enable = true;
    
    # Use stable NVIDIA package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Use proprietary driver (required for CUDA and X server)
    open = false;
    
    # Enable nvidia-settings utility
    nvidiaSettings = true;
    
    # Power management (optional, helps with power consumption)
    powerManagement.enable = true;
  };

  # X server video drivers (enabled when Steam service is active)
  # The steam.nix module will set services.xserver.videoDrivers = [ "nvidia" ]
  # This configuration ensures NVIDIA drivers work with X server

  # CUDA environment variables
  # These are needed for CUDA applications to find libraries
  environment.sessionVariables = {
    CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      "${pkgs.cudaPackages.cudatoolkit}/lib"
      "${pkgs.cudaPackages.cudatoolkit}/lib64"
      pkgs.cudaPackages.cudnn
      pkgs.cudaPackages.cuda_cudart
      pkgs.stdenv.cc.cc.lib
    ];
    CUDA_MODULE_LOADING = "LAZY";
  };

  # System packages for CUDA development
  environment.systemPackages = with pkgs; [
    # NVIDIA utilities are provided by hardware.nvidia configuration above
    # nvidia-settings is provided by hardware.nvidia.nvidiaSettings = true
    # nvidia-smi and other utilities come with the NVIDIA driver package
    
    # CUDA toolkit (for development)
    cudaPackages.cudatoolkit
    
    # Optional: CUDA samples and documentation
    # cudaPackages.cuda-samples
    # cudaPackages.cuda-docs
  ];

  # Docker NVIDIA support (if Docker is enabled)
  # Automatically configure Docker to use NVIDIA GPUs when Docker is enabled
  hardware.nvidia-container-toolkit.enable = lib.mkIf config.virtualisation.docker.enable true;
  virtualisation.docker.daemon.settings.features.cdi = lib.mkIf config.virtualisation.docker.enable true;
}
