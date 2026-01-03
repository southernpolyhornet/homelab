# NVIDIA GPU and CUDA support module
# Automatically configures for headless (CUDA/Docker) or X server use
# - If X server is enabled: uses X11 video drivers, disables datacenter mode
# - If X server is disabled: enables datacenter mode for headless/CUDA use
{ config, pkgs, lib, ... }:

{
  # Enable unfree packages (required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # NVIDIA hardware configuration
  hardware.nvidia = {
    # Enable modesetting for better compatibility
    modesetting.enable = true;
    
    # Use stable NVIDIA package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Use proprietary driver (required for CUDA)
    open = false;
    
    # Power management (optional, helps with power consumption)
    powerManagement.enable = true;
    
    # Datacenter mode is mutually exclusive with X11 video drivers
    # Enable it only if X server is not enabled (for headless/CUDA use)
    datacenter.enable = !config.services.xserver.enable;
    
    # Enable nvidia-settings utility when using X server
    nvidiaSettings = config.services.xserver.enable;
  };

  # Add NVIDIA video drivers to X server if it's enabled
  # This allows X server (from core/display) to use NVIDIA GPU
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "nvidia" ];

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
