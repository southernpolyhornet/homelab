{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix
    
    # Users
    ../../users/morgan/user.nix
    
    # Machine-specific secrets (gitignored, optional)
    (if builtins.pathExists (./. + "/secrets.nix") then ./secrets.nix else {})

    # Services
    ../../modules/services/adguard.nix
  ];

  # System state version - matches NixOS version when first installed
  # Don't change unless doing major upgrade and reading release notes
  system.stateVersion = "25.11";

  # Networking
  networking.hostName = "saturn";
  
  # Use AdGuard Home (running on this machine) as DNS server
  networking.nameservers = [ "127.0.0.1" "::1" ];
}
