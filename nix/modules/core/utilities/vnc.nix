# x11vnc VNC Server Configuration
# Provides VNC access to the existing X session
# Works with LightDM (uses /var/run/lightdm/root/:0 for XAUTHORITY)
{ config, pkgs, lib, ... }:

{
  options.services.vnc = {
    enable = lib.mkEnableOption "x11vnc VNC server";
    user = lib.mkOption {
      type = lib.types.str;
      default = "steamuser";
      description = "User whose X session to share via VNC";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5900;
      description = "VNC server port";
    };
  };

  config = lib.mkIf config.services.vnc.enable {
    # Ensure x11vnc package is available
    environment.systemPackages = with pkgs; [
      x11vnc
    ];

    # x11vnc VNC Server Configuration
    # Running as root (system service) so it can read XAUTHORITY file directly
    # LightDM stores XAUTHORITY at /var/run/lightdm/root/:0
    systemd.services.x11vnc = {
      description = "x11vnc server for existing X session";
      wantedBy = [ "graphical.target" ];
      after = [ "display-manager.service" ];
      wants = [ "display-manager.service" ];
      
      serviceConfig = {
        Type = "simple";
        # Run as root to access XAUTHORITY file
        Environment = [
          "DISPLAY=:0"
          "XAUTHORITY=/var/run/lightdm/root/:0"
        ];
        # Use explicit LightDM XAUTHORITY path
        ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -auth /var/run/lightdm/root/:0 -wait 10 -defer 10 -forever -shared -rfbauth /home/${config.services.vnc.user}/.vnc/passwd -rfbport ${toString config.services.vnc.port} -noxdamage -repeat";
        Restart = "on-failure";
        RestartSec = 10;
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    # Create .vnc directory for the configured user if it doesn't exist
    systemd.tmpfiles.rules = [
      "d /home/${config.services.vnc.user}/.vnc 0700 ${config.services.vnc.user} users -"
    ];

    # Firewall: VNC port
    networking.firewall.allowedTCPPorts = [ config.services.vnc.port ];
  };
}
