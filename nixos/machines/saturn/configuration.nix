{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix
    
    # Users
    ../../users/morgan/user.nix
    
    # Machine-specific secrets (gitignored)
    ./secrets.nix

    # Services
    ../../modules/services/adguard.nix
  ];

  # System state version - matches NixOS version when first installed
  # Don't change unless doing major upgrade and reading release notes
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "saturn";
}
