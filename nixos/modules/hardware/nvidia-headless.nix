# NVIDIA GPU and CUDA support module (headless)
# Extends nvidia-base.nix for headless CUDA/Docker workloads
# Use this when you need GPU compute but don't need graphical output
{ config, pkgs, lib, ... }:

{
  imports = [
    ./nvidia-base.nix
  ];

  # Note: nvidiaSettings is not needed for headless
  # nvidiaSettings defaults to false in base module
  # No X server video drivers needed for headless
}
