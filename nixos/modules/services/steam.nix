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
      description = "Optional Steam library path. Directory and Steam configuration will be created automatically. Steam will recognize this library on first launch.";
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

  # Create XFCE autostart entry for Steam in desktop mode (not Big Picture)
  # Use tmpfiles to create the desktop file directly in the user's home directory
  # Launch with -silent and explicitly NOT in Big Picture Mode
  systemd.tmpfiles.rules = [
    "d /home/steamuser/.config/autostart 0755 steamuser users -"
    "f /home/steamuser/.config/autostart/steam.desktop 0644 steamuser users - '[Desktop Entry]\nName=Steam\nComment=Application for managing and playing games on Steam\nExec=${pkgs.steam}/bin/steam -silent -noverifyfiles -nobootstrapupdate\nIcon=steam\nTerminal=false\nType=Application\nCategories=Network;FileTransfer;Game;\n'"
  ];

    # Activation script to create Steam library directory and configure Steam
    # Automatically adds the library path to Steam's libraryfolders.vdf
    system.activationScripts.steam-library-path = lib.mkIf (cfg.libraryPath != null) {
      text = ''
        set -euo pipefail

        LIB="${cfg.libraryPath}"

        # Create Steam library directory
        mkdir -p "$LIB/steamapps"
        chown -R steamuser:users "$LIB"

        # Allow steamuser to write; setgid bit ensures new files inherit group
        chmod 2775 "$LIB"
        chmod 2775 "$LIB/steamapps" || true
        find "$LIB" -type d -exec chmod 2775 {} \; || true

        # Ensure Steam dirs exist
        mkdir -p /home/steamuser/.local/share/Steam/steamapps
        mkdir -p /home/steamuser/.local/share/Steam/config
        mkdir -p /home/steamuser/.steam

        # Make sure ~/.steam/steam points to ~/.local/share/Steam
        if [ ! -e /home/steamuser/.steam/steam ]; then
          ln -s /home/steamuser/.local/share/Steam /home/steamuser/.steam/steam
        fi

        chown -R steamuser:users /home/steamuser/.steam
        chown -R steamuser:users /home/steamuser/.local/share/Steam

        # Write libraryfolders.vdf with the REAL path (unquoted heredoc for variable expansion)
        cat > /home/steamuser/.local/share/Steam/steamapps/libraryfolders.vdf <<EOF
"libraryfolders"
{
  "0"
  {
    "path"    "/home/steamuser/.steam/steam"
    "label"   ""
  }
  "1"
  {
    "path"    "$LIB"
    "label"   ""
  }
}
EOF

        chown steamuser:users /home/steamuser/.local/share/Steam/steamapps/libraryfolders.vdf
        chmod 0644 /home/steamuser/.local/share/Steam/steamapps/libraryfolders.vdf
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
