# Hardware configuration for saturn
# This file will be generated/updated by nixos-anywhere during installation
# Minimal placeholder to satisfy flake check

{ config, lib, pkgs, modulesPath, ... }:

{
  # Minimal filesystem configuration
  # nixos-anywhere will replace this with actual filesystem setup during installation
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000"; # Placeholder
    fsType = "ext4"; # Placeholder
  };

  # Boot loader will be configured by nixos-anywhere
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
}
