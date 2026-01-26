# Sunshine game streaming server module
# Self-hosted game streaming server for Moonlight clients
# Supports hardware encoding on AMD, Intel, and NVIDIA GPUs
# 
# Sunshine runs as a user service and starts automatically on login
# Web UI: https://localhost:47990
# Streaming port: 47989 (UDP/TCP)
#
# Usage: Set services.sunshine.enable = true in your configuration
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.services.sunshine.enable {
    # Configure Sunshine with sensible defaults for X11 gaming setup
    services.sunshine = {
      autoStart = true;  # Start automatically on login
      capSysAdmin = false;  # Not needed for X11 (only for Wayland)
      openFirewall = true;  # Open ports 47989 (streaming) and 47990 (web UI)
    };

    # Additional environment for Sunshine user service
    # Ensure it has access to DISPLAY and NVIDIA libraries for hardware encoding
    systemd.user.services.sunshine = {
      serviceConfig.Environment = lib.mkMerge [
        (lib.mkIf (config.hardware.nvidia != null) [
          "LD_LIBRARY_PATH=${lib.makeLibraryPath [ config.boot.kernelPackages.nvidiaPackages.stable ]}:$LD_LIBRARY_PATH"
        ])
        [
          "DISPLAY=:0"
        ]
      ];
    };
  };
}
