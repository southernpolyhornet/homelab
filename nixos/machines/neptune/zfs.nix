# ZFS configuration for neptune

{ config, pkgs, lib, ... }:

{
  networking.hostId = "01520311";

  # ZFS filesystem support
  boot.supportedFilesystems = [ "zfs" ];
  
  # Import the toshiba14T pool
  boot.zfs.extraPools = [ "toshiba14T" ];
  
  # Automatic ZFS maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true; # Optional for HDD-only pools
  
  # ZFS datasets will auto-mount via zfs-mount service
  # Datasets have mountpoint=/tank/toshiba14T/* and canmount=on set
  # No need for explicit fileSystems entries - ZFS handles mounting automatically
}
