# Base NVIDIA GPU and CUDA support module
# Common configuration shared by nvidia.nix and nvidia-headless.nix
{ config, pkgs, lib, ... }:

{
  # Enable unfree packages (required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # NVIDIA hardware configuration (common settings)
  hardware.nvidia = {
    # Enable modesetting for better compatibility
    modesetting.enable = true;
    
    # Use stable NVIDIA package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Use proprietary driver (required for CUDA)
    open = false;
    
    # Power management (optional, helps with power consumption)
    powerManagement.enable = true;
    
    # Enable datacenter mode (required for nvidia-container-toolkit)
    datacenter.enable = true;
  };

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
