# NVIDIA GPU and CUDA support module
# Extends nvidia-base.nix with X server support
# Use this when you need both CUDA/Docker and X server (e.g., for Steam)
{ config, pkgs, lib, ... }:

{
  imports = [
    ./nvidia-base.nix
  ];

  # Enable nvidia-settings utility (useful for X server)
  hardware.nvidia.nvidiaSettings = true;

  # Add NVIDIA video drivers to X server if it's enabled
  # This allows X server (from core/display) to use NVIDIA GPU
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "nvidia" ];
}
