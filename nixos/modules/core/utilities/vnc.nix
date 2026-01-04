# VNC server configuration using x11vnc
# Shares the existing :0 display for remote access
{ config, pkgs, lib, ... }:

let
  cfg = config.services.vnc;
in
{
  options.services.vnc = {
    enable = lib.mkEnableOption "VNC server using x11vnc";
    user = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "User to run x11vnc service for. If empty, service won't start.";
      example = "steamuser";
    };
  };

  config = lib.mkIf cfg.enable {
    # x11vnc to share the existing :0 display
    # This runs as a systemd user service
    systemd.user.services.x11vnc = lib.mkIf (cfg.user != "") {
      description = "x11vnc server for existing X session";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        Environment = [
          "DISPLAY=:0"
          "XAUTHORITY=/var/run/lightdm/root/:0"
        ];
        ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -auth /var/run/lightdm/root/:0 -forever -shared -rfbauth %h/.vnc/passwd -noxdamage -repeat -loop";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    # Create .vnc directory for the configured user
    systemd.tmpfiles.rules = lib.mkIf (cfg.user != "") [
      "d /home/${cfg.user}/.vnc 0700 ${cfg.user} users -"
    ];

    # Firewall: VNC uses port 5900
    networking.firewall.allowedTCPPorts = [ 5900 ];

    # System packages
    environment.systemPackages = [ pkgs.x11vnc ];
  };
}
