# Base X server configuration
# Provides base X server infrastructure that display managers and window managers depend on
{ config, pkgs, lib, ... }:

{
  # Enable X server
  services.xserver = {
    enable = true;
    
    # X server keyboard configuration
    xkb = {
      layout = "us";
      options = "eurosign:e";
    };
  };
}
