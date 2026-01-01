{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix

    # Users
    ../../users/morgan/user.nix

    # ZFS configuration
    ./zfs.nix

    # Machine-specific secrets (gitignored)
    # Contains: Tailscale auth key
    (if builtins.pathExists ./secrets.nix then ./secrets.nix else {})
  ];

  # System state version - matches NixOS version when first installed
  # Don't change unless doing major upgrade and reading release notes
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "neptune";

}
