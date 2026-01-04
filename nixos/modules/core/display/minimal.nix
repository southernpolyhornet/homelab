# Minimal X server configuration
# Provides base X server infrastructure that can be enhanced by hardware and service modules
{ config, pkgs, lib, ... }:

{
  # Enable X server (minimal configuration)
  services.xserver = {
    enable = true;
    
    # X server keyboard configuration
    xkb = {
      layout = "us";
      options = "eurosign:e";
    };
    
    # Video drivers will be added by hardware modules (e.g., nvidia.nix)
    # Desktop environment will be added by service modules (e.g., steam.nix)
  };

  # System service to allow local X connections (runs as root to access X server)
  # This runs after display-manager starts, enabling X access for all users and services
  systemd.services.xhost-local = {
    description = "Allow local X connections";
    wantedBy = [ "display-manager.service" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      # Wait for X server to be ready, then run xhost
      ExecStart = pkgs.writeShellScript "xhost-local-start" ''
        set -e
        XAUTH_FILE="/var/run/lightdm/root/:0"
        DISPLAY=":0"
        
        # Wait for X authority file to exist (up to 10 seconds)
        for i in $(seq 1 10); do
          if [ -f "$XAUTH_FILE" ]; then
            break
          fi
          sleep 1
        done
        
        # Wait for X server to be ready and retry xhost (up to 10 attempts)
        export DISPLAY="$DISPLAY"
        export XAUTHORITY="$XAUTH_FILE"
        for i in $(seq 1 10); do
          if ${pkgs.xorg.xhost}/bin/xhost +local: 2>/dev/null; then
            exit 0
          fi
          sleep 1
        done
        
        # If we get here, xhost failed
        echo "Failed to run xhost after 10 attempts" >&2
        exit 1
      '';
      RemainAfterExit = true;
    };
  };
}
