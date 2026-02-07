{ config, pkgs, lib, ... }:

{
  imports = [
    # Default
    ../../modules/default.nix

    # SOPS secrets management
    ../../modules/sops.nix

    # Core modules (load first - foundational infrastructure)
    # Display infrastructure
    ../../modules/core/display/xserver.nix
    ../../modules/core/display/display_managers/lightdm.nix
    ../../modules/core/display/window_managers/xfce.nix
    
    # Remote access utilities
    ../../modules/core/utilities/vnc.nix
    ../../modules/core/utilities/xrdp.nix

    # Hardware modules (enhance core with hardware-specific config)
    ../../modules/hardware/nvidia.nix

    # Service modules (use core + hardware, add service-specific config)
    ../../modules/services/jellyfin.nix
    ../../modules/services/steam.nix
    ../../modules/services/sunshine.nix

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

  # Enable VNC service
  services.vnc = {
    enable = true;
    user = "steamuser";
    port = 5900;
  };

  # Jellyfin media server (NVENC enabled via module when NVIDIA present)
  # Web UI: http://<host>:8096
  services.jellyfin.enable = true;

  # Enable Sunshine game streaming server
  # Web UI: https://localhost:47990
  # Connect Moonlight clients to this host on port 47989
  services.sunshine.enable = true;

  # Steam library configuration
  # Directory will be created with proper permissions
  # Add it in Steam via Settings > Storage after Steam starts
  services.steam.libraryPath = "/tank/toshiba14T/games/steam";

  # Ensure Steam library directory on ZFS has correct permissions
  # Uses systemd-tmpfiles for cleaner declarative management
  systemd.tmpfiles.rules = [
    "d /tank/toshiba14T/games/steam 0755 steamuser users -"
  ];
}
