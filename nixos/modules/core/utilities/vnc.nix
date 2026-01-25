# VNC server configuration using x11vnc
# Shares the existing :0 display for remote access
{ config, pkgs, lib, ... }:

let
  cfg = config.services.vnc;
  # Determine XAUTH file path based on which display manager is enabled
  # SDDM uses /run/sddm/xauth_* with random filename, so we'll use -findauth
  xauthFile = 
    if config.services.displayManager.sddm.enable or false then
      # SDDM uses random filename, x11vnc will find it with -findauth
      null
    else if config.services.displayManager.lightdm.enable or false then
      "/var/run/lightdm/root/:0"
    else
      # Fallback - try to detect from common locations
      null;
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
        ] ++ lib.optional (xauthFile != null) "XAUTHORITY=${xauthFile}";
        # For SDDM, use -findauth to automatically find the xauth file
        # For LightDM, use explicit path
        ExecStart = if xauthFile != null then
          "${pkgs.x11vnc}/bin/x11vnc -display :0 -auth ${xauthFile} -forever -shared -rfbauth %h/.vnc/passwd -noxdamage -repeat -loop"
        else
          "${pkgs.x11vnc}/bin/x11vnc -display :0 -findauth -forever -shared -rfbauth %h/.vnc/passwd -noxdamage -repeat -loop";
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
