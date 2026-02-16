# ZFS configuration for neptune

{ config, pkgs, lib, ... }:

let
  zfsPkg = pkgs.zfs_unstable or pkgs.zfs;
in
{
  networking.hostId = "007f0200";

  boot.supportedFilesystems = [ "zfs" ];

  # Build ZFS kernel modules for the running kernelPackages
  boot.extraModulePackages = [
    config.boot.kernelPackages.${zfsPkg.kernelModuleAttribute}
  ];

  environment.systemPackages = [
    zfsPkg
  ];
}
# {
#   # networking.hostId = "01520311";  # Old hostId from previous system
#   networking.hostId = "007f0200";  # Current system hostId - MUST match output of `hostid` command

#   # ZFS filesystem support
#   boot.supportedFilesystems = [ "zfs" ];
  
#   # Import the toshiba14T pool
#   boot.zfs.extraPools = [ "toshiba14T" ];
  
#   # CRITICAL: Make ZFS non-blocking so system boots even if ZFS fails
#   # This prevents emergency mode and allows remote access via Tailscale/SSH for debugging
#   boot.zfs.forceImportRoot = false;
#   boot.zfs.forceImportAll = false;
  
#   # Make ZFS import service non-fatal - allows boot to continue if pool import fails
#   systemd.services.zfs-import-toshiba14T = {
#     wantedBy = lib.mkForce [ ];  # Don't block boot waiting for this
#     before = lib.mkForce [ ];     # Don't make other services wait for this
#   };
  
#   # Automatic ZFS maintenance
#   services.zfs.autoScrub.enable = true;
#   services.zfs.trim.enable = true; # Optional for HDD-only pools
  
#   # ZFS datasets will auto-mount via zfs-mount service
#   # Datasets have mountpoint=/tank/toshiba14T/* and canmount=on set
# }
