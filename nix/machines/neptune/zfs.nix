# ZFS configuration for neptune

{ config, pkgs, lib, ... }:

{
  networking.hostId = "007f0200";
  boot.supportedFilesystems = [ "zfs" ];
  # Use ZFS unstable for better kernel compatibility with kernel 6.18
  boot.zfs.package = pkgs.zfs_unstable;
  boot.zfs.extraPools = [ "toshiba14T" "samsung860evo500" ];
  
  # CRITICAL: Make ZFS non-blocking so system boots even if ZFS fails
  # This prevents emergency mode and allows remote access via Tailscale/SSH for debugging
  boot.zfs.forceImportRoot = false;
  boot.zfs.forceImportAll = false;
  
  # Run import at boot so pool (and zfs-mount-toshiba14T) run. Boot is not blocked on
  # success (nothing Requires this); if the disk is missing the import fails and boot continues.
  systemd.services.zfs-import-toshiba14T = {
    wantedBy = [ "multi-user.target" ];
  };

  # Ensure all datasets mount after this pool is imported.
  systemd.services.zfs-mount-toshiba14T = {
    description = "Mount all toshiba14T datasets after pool import";
    after = [ "zfs-import-toshiba14T.service" ];
    wantedBy = [ "zfs-import-toshiba14T.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if zpool list toshiba14T &>/dev/null; then
        zfs mount -a
      fi
    '';
  };

  # Automatic ZFS maintenance
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;  # For maintaining SSD health (safe for HDDs too)

  # Add ZFS utilities to system packages
  environment.systemPackages = with pkgs; [
    zfs_unstable
  ];
}
