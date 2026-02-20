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
    ../../modules/services/adguard.nix
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
  networking.wireless.enable = lib.mkForce false;
  
  # Static IP configuration for enp2s0
  networking.interfaces.enp2s0.ipv4.addresses = [{
    address = "192.168.0.5";
    prefixLength = 24;
  }];
  
  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
    ethtool
    pciutils
  ];

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
  # Directory and Steam configuration will be created automatically
  # Steam will recognize this library immediately on launch
  services.steam.libraryPath = "/tank/toshiba14T/games/steam";
}
