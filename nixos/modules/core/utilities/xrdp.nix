# RDP server configuration using xrdp
# Provides remote desktop access to the X server display
{ config, pkgs, lib, ... }:

{
  # Enable xrdp for RDP remote desktop access
  services.xrdp = {
    enable = true;
    # Default port (can be changed if needed)
    port = 3389;
    # Open firewall for RDP
    openFirewall = true;
  };

  # xrdp configuration
  # xrdp will automatically create sessions for users
  # It uses X11/Xorg sessions by default
  
  # Note: xrdp creates its own X sessions, but we want it to connect to the existing :0 display
  # For connecting to an existing X session, we might need to use xrdp with x11vnc backend
  # or configure xrdp to use the existing display
  
  # Alternative: Use xrdp with X11 session that connects to :0
  # This requires additional configuration in /etc/xrdp/xrdp.ini
  # For now, xrdp will create new X sessions for each RDP connection
  # To share the existing :0 display, we'd need x11vnc or similar
  
  # Firewall: RDP uses port 3389 (handled by openFirewall above)
  
  # To connect: Use any RDP client (mstsc on Windows, Remmina, rdesktop, etc.)
  # Connect to: neptune:3389
  # Login with: steamuser (or any system user)
}
