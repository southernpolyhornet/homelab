# ZFS configuration for neptune

{ config, pkgs, lib, ... }:

{
  # Current system hostId - MUST match output of `hostid` command
  networking.hostId = "007f0200";

  # ZFS filesystem support - automatically builds kernel modules
  boot.supportedFilesystems = [ "zfs" ];

  # Use ZFS unstable for better kernel compatibility with kernel 6.18
  boot.zfs.package = pkgs.zfs_unstable;
  
  # Import the toshiba14T pool at boot
  boot.zfs.extraPools = [ "toshiba14T" ];
  
  # CRITICAL: Make ZFS non-blocking so system boots even if ZFS fails
  # This prevents emergency mode and allows remote access via Tailscale/SSH for debugging
  boot.zfs.forceImportRoot = false;
  boot.zfs.forceImportAll = false;
  
  # Make ZFS import service non-fatal - allows boot to continue if pool import fails
  systemd.services.zfs-import-toshiba14T = {
    wantedBy = lib.mkForce [ ];  # Don't block boot waiting for this
    before = lib.mkForce [ ];     # Don't make other services wait for this
  };
  
  # Automatic ZFS maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;  # For maintaining SSD health (safe for HDDs too)

  # Add ZFS utilities to system packages
  environment.systemPackages = with pkgs; [
    zfs_unstable
  ];
  
  # ZFS datasets will auto-mount via zfs-mount service
  # Datasets have mountpoint=/tank/toshiba14T/* and canmount=on set
}
