# LightDM display manager configuration
# Minimal display manager, good for lightweight setups
{ config, pkgs, lib, ... }:

{
  # LightDM display manager
  services.xserver.displayManager.lightdm = {
    enable = true;
    # Use minimal greeter (required even with auto-login)
    greeters.gtk.enable = true;
  };

  # System service to allow local X connections (runs as root to access X server)
  # This runs after display-manager starts, enabling X access for all users and services
  # LightDM-specific XAUTH file location
  systemd.services.xhost-local = {
    description = "Allow local X connections";
    wantedBy = [ "display-manager.service" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "xhost-local-start" ''
        set -e
        XAUTH_FILE="/var/run/lightdm/root/:0"
        DISPLAY=":0"
        
        for i in $(seq 1 10); do
          if [ -f "$XAUTH_FILE" ]; then
            break
          fi
          sleep 1
        done
        
        export DISPLAY="$DISPLAY"
        export XAUTHORITY="$XAUTH_FILE"
        for i in $(seq 1 10); do
          if ${pkgs.xhost}/bin/xhost +local: 2>/dev/null; then
            exit 0
          fi
          sleep 1
        done

        echo "Failed to run xhost after 10 attempts" >&2
        exit 1
      '';
      RemainAfterExit = true;
    };
  };
}
