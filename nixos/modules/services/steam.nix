# Steam service module
# Sets up Steam as a host-level service with dedicated user and X server
{ config, pkgs, lib, ... }:

{
  # Enable Steam program (includes Steam runtime and dependencies)
  programs.steam = {
    enable = true;
    # Enable Steam hardware support (controllers, etc.)
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable X server for Steam
  services.xserver = {
    enable = true;
    
    # Use NVIDIA video drivers
    videoDrivers = [ "nvidia" ];
    
    # X server keyboard configuration
    xkb = {
      layout = "us";
      options = "eurosign:e";
    };
  };

  # Display manager configuration
  services.displayManager = {
    # Default session (required for auto-login)
    # Use xterm session (minimal, just provides X server)
    defaultSession = "xterm";
    
    # Auto-login steamuser on boot
    autoLogin = {
      enable = true;
      user = "steamuser";
    };
  };

  # LightDM display manager (must be under services.xserver.displayManager)
  services.xserver.displayManager.lightdm = {
    enable = true;
    # Use minimal greeter (required even with auto-login)
    greeters.gtk.enable = true;
  };

  # Desktop environment (minimal, just for X server)
  services.xserver.desktopManager = {
    xterm.enable = true;
  };

  # Systemd user service to auto-start Steam
  # This will be created in steamuser's home directory
  systemd.user.services.steam = {
    description = "Steam service";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.steam}/bin/steam -silent";
      Restart = "on-failure";
      RestartSec = "10";
      # Environment variables for Steam
      Environment = [
        "DISPLAY=:0"
        "XDG_RUNTIME_DIR=/run/user/%U"
      ];
    };
  };

  # Firewall rules for Steam Remote Play
  # Steam Remote Play uses UDP ports 27031-27036
  networking.firewall = {
    allowedUDPPorts = [ 27031 27032 27033 27034 27035 27036 ];
    # Steam also uses various TCP ports for game streaming
    allowedTCPPorts = [ 27036 ];
  };

  # Additional packages for Steam
  environment.systemPackages = with pkgs; [
    # Steam is included via programs.steam.enable
    # Add any additional Steam-related tools here if needed
  ];
}
