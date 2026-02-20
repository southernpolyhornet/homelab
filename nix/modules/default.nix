{ config, pkgs, lib, ... }:

{

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Binary caches for faster builds and signed packages
    substituters = [ "https://cache.nixos.org" "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Boot Configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Time zone
  time.timeZone = "America/Chicago";

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console keyboard layout
  console.keyMap = "us";

  # Tailscale VPN
  services.tailscale = {
    enable = true;
  };

  # Networking configuration
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    firewall.trustedInterfaces = [ "tailscale0" ];
    firewall.allowedUDPPorts = [ 41641 ];
    firewall.allowedTCPPorts = [ 22 ];
  };

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      # Temporarily enable root login for initial deployment
      # TODO: Disable after deployment if desired
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      # Enable X11 forwarding
      X11Forwarding = true;
      X11UseLocalhost = false;  # Allow forwarding to remote X servers
    };
  };

  # Base system packages
  # Temporarily disabled most packages
  environment.systemPackages = with pkgs; [
    nano
    git
    curl
    wget
    ffmpeg
    net-tools
    gawk
    lshw
    nmap
    pciutils
  ];

  # Virtualisation
  virtualisation = {
    docker = {
      enable = true;
    };
  };

  # Activation script to update user passwords from hashedPasswordFile
  # This handles the case where users exist but passwords need to be updated
  # (mutableUsers = true means passwords aren't updated automatically)
  system.activationScripts.updateUserPasswords = lib.mkIf config.users.mutableUsers {
    text = ''
      # Update passwords for users with hashedPasswordFile set
      ${lib.concatMapStringsSep "\n" (name: let user = config.users.users.${name}; in ''
        if [ -n "${toString user.hashedPasswordFile}" ] && [ -f "${toString user.hashedPasswordFile}" ]; then
          ${pkgs.shadow}/bin/usermod -p "$(cat ${toString user.hashedPasswordFile})" ${lib.escapeShellArg name} 2>/dev/null || true
        fi
      '') (lib.attrNames (lib.filterAttrs (n: u: u.hashedPasswordFile != null) config.users.users))}
    '';
    deps = [ "setupSecretsForUsers" "users" ];
  };
}