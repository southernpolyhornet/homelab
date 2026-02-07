# SDDM display manager configuration
# Modern, Qt-based display manager with good auto-login support
{ config, pkgs, lib, ... }:

{
  # SDDM display manager
  services.displayManager.sddm = {
    enable = true;
    # Optional: customize theme if desired
    # theme = "breeze";
  };
}
