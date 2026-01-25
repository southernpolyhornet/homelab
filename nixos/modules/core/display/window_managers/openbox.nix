# Openbox window manager configuration
# Lightweight standalone window manager - minimal but functional
# Good for Steam and other GUI apps without the overhead of a full desktop environment
{ config, pkgs, lib, ... }:

{
  # Openbox window manager
  services.xserver.windowManager.openbox = {
    enable = true;
  };

  # Set default session to Openbox
  services.xserver.displayManager.defaultSession = "none+openbox";

  # Additional packages for Openbox
  environment.systemPackages = with pkgs; [
    openbox
    # Optional: add a panel or launcher if desired
    # tint2  # Lightweight panel
    # rofi   # Application launcher
  ];
}
