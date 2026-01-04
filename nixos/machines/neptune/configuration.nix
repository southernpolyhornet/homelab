{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix

    # SOPS secrets management
    ../../modules/sops.nix

    # Core modules (load first - foundational infrastructure)
    ../../modules/core/display/minimal.nix
    ../../modules/core/utilities/vnc.nix
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

  # Steam library configuration
  # Directory will be created with proper permissions
  # Add it in Steam via Settings > Storage after Steam starts
  services.steam.libraryPath = "/tank/toshiba14T/games/steam";

  # Ensure Steam library directory on ZFS has correct permissions
  # Uses systemd-tmpfiles for cleaner declarative management
  systemd.tmpfiles.rules = [
    "d /tank/toshiba14T/games/steam 0755 steamuser users -"
  ];

  # VNC configuration for steamuser
  # User must set VNC password manually: ssh steamuser@neptune 'x11vnc -storepasswd'
  services.vnc = {
    enable = true;
    user = "steamuser";
  };
}
