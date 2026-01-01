{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix

    # Users
    ../../users/morgan/user.nix

    # Machine-specific secrets (gitignored, optional)
    (if builtins.pathExists (./. + "/secrets.nix") then ./secrets.nix else {})
  ];

  # System state version - matches NixOS version when first installed
  # Don't change unless doing major upgrade and reading release notes
  system.stateVersion = "25.11";

  # ZFS configuration
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "toshiba14T" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true; # Optional for HDD-only pools
  
  # ZFS datasets will auto-mount via zfs-mount service
  # Datasets have mountpoint=/tank/toshiba14T/* and canmount=on set
  # No need for explicit fileSystems entries - ZFS handles mounting automatically

  # Networking
  networking.hostName = "neptune";

}
