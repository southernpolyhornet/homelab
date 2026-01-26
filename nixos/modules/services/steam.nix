# Steam service module
# Sets up Steam as a host-level service with dedicated user and X server
{ config, pkgs, lib, ... }:

let
  cfg = config.services.steam;
in
{
  options.services.steam = {
    libraryPath = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "Optional Steam library path. Directory will be created with proper permissions for steamuser. Steam will set it up when you add it through Settings > Storage.";
      example = "/mnt/games/steam";
    };
  };

  config = {
    # Enable Steam program (includes Steam runtime and dependencies)
    programs.steam = {
      enable = true;
      # Enable Steam hardware support (controllers, etc.)
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

  # Display manager configuration
  # Auto-login steamuser on boot
  # Note: Display manager and window manager should be configured in display modules
  services.displayManager.autoLogin = {
    enable = true;
    user = "steamuser";
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
      ExecStart = "${pkgs.steam}/bin/steam";
      Restart = "on-failure";
      RestartSec = "10";
      # Environment variables for Steam
      # Optimized for Steam Remote Play with NVIDIA hardware encoding
      Environment = [
        "DISPLAY=:0"
        "XDG_RUNTIME_DIR=/run/user/%U"
        "__GL_SYNC_TO_VBLANK=0"
        "__GL_YIELD=NOTHING"
        "LD_LIBRARY_PATH=${lib.makeLibraryPath [ config.boot.kernelPackages.nvidiaPackages.stable ]}:$LD_LIBRARY_PATH"
        "STEAM_COMPAT_CLIENT_INSTALL_PATH=/home/steamuser/.steam"
        "STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0"
        "NVENC_PRESET=low_latency"
      ];
    };
  };

    # Activation script to create Steam library directory with proper permissions
    # Steam will handle setting it up when you add it through Settings > Storage
    system.activationScripts.steam-library-path = lib.mkIf (cfg.libraryPath != null) {
      text = ''
        # Create Steam library directory if configured
        if [ -n "${lib.escapeShellArg cfg.libraryPath}" ]; then
          mkdir -p "${lib.escapeShellArg cfg.libraryPath}"
          chown steamuser:users "${lib.escapeShellArg cfg.libraryPath}"
          chmod 755 "${lib.escapeShellArg cfg.libraryPath}"
        fi
      '';
      deps = [ "users" ];
    };

    # Firewall rules for Steam Remote Play
    # Steam Remote Play uses UDP ports 27031-27036
    networking.firewall = {
      allowedUDPPorts = [ 27031 27032 27033 27034 27035 27036 ];
      allowedTCPPorts = [ 27036 ];
    };

    # Additional packages for Steam
    environment.systemPackages = with pkgs; [
      # Steam is included via programs.steam.enable
      # Add any additional Steam-related tools here if needed
    ];
  };
}
