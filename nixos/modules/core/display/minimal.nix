# Minimal X server configuration
# Provides base X server infrastructure that can be enhanced by hardware and service modules
{ config, pkgs, lib, ... }:

{
  # Enable X server (minimal configuration)
  services.xserver = {
    enable = true;
    
    # X server keyboard configuration
    xkb = {
      layout = "us";
      options = "eurosign:e";
    };
    
    # Video drivers will be added by hardware modules (e.g., nvidia.nix)
    # Desktop environment will be added by service modules (e.g., steam.nix)
  };
}
