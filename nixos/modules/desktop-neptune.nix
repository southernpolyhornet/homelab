# Full Desktop Display and VNC Configuration for Neptune
# Consolidates X server, SDDM, XFCE, and x11vnc into a single module for easier debugging.
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

    # 2. SDDM Display Manager
    displayManager.sddm = {
      enable = true;
      # We rely on steam.nix for auto-login to steamuser
      # theme = "breeze"; # Optional: customize theme if desired
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
    x11vnc # Ensure x11vnc is available system-wide
  ];

  # 4. x11vnc VNC Server Configuration
  # This runs as a systemd user service for steamuser
  # It shares the existing :0 display for remote access
  systemd.user.services.x11vnc = {
    description = "x11vnc server for existing X session";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    
    # Ensure x11vnc environment gets a full PATH for -findauth
    # We use lib.mkForce to ensure our PATH definition takes precedence
    environment.PATH = lib.mkForce (lib.makeBinPath [ pkgs.x11vnc pkgs.gawk pkgs.nettools pkgs.coreutils pkgs.findutils pkgs.gnugrep pkgs.bash ] + ":/run/current-system/sw/bin");

    serviceConfig = {
      Type = "simple";
      User = steamUser; # Explicitly run as steamuser
      # DISPLAY and XAUTHORITY should be inherited from the user's X session via systemd environment
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -findauth -forever -shared -rfbauth /home/${steamUser}/.vnc/passwd -noxdamage -repeat -loop";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  # Create .vnc directory for the configured user if it doesn't exist
  systemd.tmpfiles.rules = [
    "d /home/${steamUser}/.vnc 0700 ${steamUser} users -"
  ];

  # Firewall: VNC uses port 5900
  networking.firewall.allowedTCPPorts = [ 5900 ];
}
