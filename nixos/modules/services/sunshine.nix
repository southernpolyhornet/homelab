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

    # Ensure Sunshine config directory exists with proper permissions
    # Sunshine stores config in ~/.config/sunshine/
    # Credentials are stored in ~/.config/sunshine/credentials/
    systemd.tmpfiles.rules = [
      "d /home/steamuser/.config/sunshine 0755 steamuser users -"
      "d /home/steamuser/.config/sunshine/credentials 0755 steamuser users -"
    ];

    # Fix read-only apps.json issue
    # If apps.json exists and is read-only, make it writable
    system.activationScripts.sunshine-fix-permissions = ''
      if [ -f /home/steamuser/.config/sunshine/apps.json ] && [ ! -w /home/steamuser/.config/sunshine/apps.json ]; then
        chmod 644 /home/steamuser/.config/sunshine/apps.json
        chown steamuser:users /home/steamuser/.config/sunshine/apps.json
      fi
    '';

    # Additional environment and dependencies for Sunshine user service
    # Ensure it has access to X11 display and NVIDIA libraries for hardware encoding
    systemd.user.services.sunshine = {
      # Wait for graphical session to be ready
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      
      serviceConfig = {
        Environment = lib.mkMerge [
          [
            "DISPLAY=:0"
            "XAUTHORITY=/var/run/lightdm/root/:0"
            "XDG_SESSION_TYPE=x11"
          ]
          (lib.mkIf (config.hardware.nvidia != null) [
            "LD_LIBRARY_PATH=${lib.makeLibraryPath [ config.boot.kernelPackages.nvidiaPackages.stable ]}:$LD_LIBRARY_PATH"
          ])
        ];
        ExecStartPre = lib.mkDefault "${pkgs.coreutils}/bin/sleep 5";
      };
    };
  };
}
