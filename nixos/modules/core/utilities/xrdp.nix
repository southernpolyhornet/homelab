# RDP server configuration using xrdp
# Creates new X sessions for users (steamuser should use VNC to access existing :0)
{ config, pkgs, lib, ... }:

{
  # Enable xrdp for RDP remote desktop access
  # This creates new X sessions for users who connect via RDP
  services.xrdp = {
    enable = true;
    port = 3389;
    openFirewall = true;
    # Use xterm as the default window manager for new RDP sessions
    defaultWindowManager = "xterm";
  };

  # Ensure xterm is available system-wide for xrdp
  environment.systemPackages = [ pkgs.xterm ];

  # Custom startwm.sh to start xterm window manager
  # xrdp creates its own X server, we just need to start the window manager
  environment.etc."xrdp/startwm.sh" = {
    text = ''
      #!/bin/sh
      # Source profile for PATH
      if [ -r /etc/profile ]; then
        . /etc/profile
      fi

      # xrdp has already started X, just start xterm as the window manager
      # xterm should be in PATH via systemPackages
      exec xterm
    '';
    mode = "0755";
  };
}
