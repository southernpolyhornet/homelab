# Full Desktop Display and VNC Configuration for Neptune
# Consolidates X server, LightDM, XFCE, and x11vnc into a single module for easier debugging.
# LightDM is used instead of SDDM because it has a predictable XAUTHORITY location.
{ config, pkgs, lib, ... }:

let
  steamUser = "steamuser"; # Define steamuser for clarity and reusability
in
{
  # 1. Base X Server Configuration
  services.xserver = {
    enable = true;
    
    xkb = {
      layout = "us";
      options = "eurosign:e";
    };

    # 2. LightDM Display Manager
    # LightDM has predictable XAUTHORITY location (/var/run/lightdm/root/:0)
    # which makes it much easier to configure VNC access
    displayManager.lightdm = {
      enable = true;
      # Use minimal greeter (required even with auto-login)
      greeters.gtk.enable = true;
    };

    # 3. XFCE Desktop Environment
    desktopManager.xfce = {
      enable = true;
      enableXfwm = true;  # Window manager
      noDesktop = true;   # Minimal UI for headless/Steam use
    };

    # Set default session to XFCE
    displayManager.defaultSession = "xfce";
  };

  # Ensure essential XFCE components and dbus are available
  environment.systemPackages = with pkgs; [
    xfce.thunar
    xfce.xfce4-terminal
    xfce.xfce4-session
    dbus
    x11vnc
  ];

  # 4. x11vnc VNC Server Configuration
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
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -auth /var/run/lightdm/root/:0 -wait 10 -defer 10 -forever -shared -rfbauth /home/${steamUser}/.vnc/passwd -rfbport 5900 -noxdamage -repeat";
      Restart = "on-failure";
      RestartSec = 10;
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Create .vnc directory for the configured user if it doesn't exist
  systemd.tmpfiles.rules = [
    "d /home/${steamUser}/.vnc 0700 ${steamUser} users -"
  ];

  # Firewall: VNC uses port 5900
  networking.firewall.allowedTCPPorts = [ 5900 ];
}
