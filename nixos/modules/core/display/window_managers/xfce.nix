# XFCE desktop environment configuration
# Lightweight but full-featured desktop environment with proper window manager
# Good for Steam and other GUI applications
{ config, pkgs, lib, ... }:

{
  # XFCE desktop environment
  services.xserver.desktopManager.xfce = {
    enable = true;
    # Disable some XFCE services we don't need for headless/Steam use
    enableXfwm = true;  # Window manager
    noDesktop = true;   # Don't show desktop icons/panels (minimal UI)
  };

  # Set default session to XFCE
  services.xserver.displayManager.defaultSession = "xfce";

  # Additional packages for XFCE
  environment.systemPackages = with pkgs; [
    # XFCE includes most things, but add any extras if needed
  ];
}
