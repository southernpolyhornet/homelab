{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix

    # SOPS secrets management
    ../../modules/sops.nix

    # Core modules (load first - foundational infrastructure)
    ../../modules/core/display/minimal.nix
    ../../modules/core/utilities/xrdp.nix

    # Hardware modules (enhance core with hardware-specific config)
    ../../modules/hardware/nvidia.nix

    # Service modules (use core + hardware, add service-specific config)
    ../../modules/services/steam.nix

    # Users
    ../../users/morgan/user.nix
    ../../users/steamuser/user.nix

    # Machine-specific configuration
    ./zfs.nix
    ./secrets.nix
  ];

  # System state version - matches NixOS version when first installed
  # Don't change unless doing major upgrade and reading release notes
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "neptune";
}
