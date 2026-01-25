# SDDM display manager configuration
# Modern, Qt-based display manager with good auto-login support
{ config, pkgs, lib, ... }:

{
  # SDDM display manager
  services.xserver.displayManager.sddm = {
    enable = true;
    # Optional: customize theme if desired
    # theme = "breeze";
  };

  # System service to allow local X connections (runs as root to access X server)
  # This runs after display-manager starts, enabling X access for all users and services
  # SDDM-specific XAUTH file location
  systemd.services.xhost-local = {
    description = "Allow local X connections";
    wantedBy = [ "display-manager.service" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "xhost-local-start" ''
        set -e
        # SDDM uses different XAUTH file location than lightdm
        XAUTH_FILE="/var/lib/sddm/:0"
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
          if ${pkgs.xorg.xhost}/bin/xhost +local: 2>/dev/null; then
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
