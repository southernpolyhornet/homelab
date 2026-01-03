{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix

    # SOPS secrets management
    ../../modules/sops.nix

    # Users
    ../../users/morgan/user.nix
    # ../../users/steamuser/user.nix

    # Hardware
    # ../../modules/hardware/nvidia.nix

    # Services
    # ../../modules/services/steam.nix

    # ZFS configuration
    ./zfs.nix

    # Machine-specific SOPS secrets
    ./secrets.nix
  ];

  # System state version - matches NixOS version when first installed
  # Don't change unless doing major upgrade and reading release notes
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "neptune";
}
