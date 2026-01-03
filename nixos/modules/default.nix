{ config, pkgs, lib, ... }:

{

  # Nix configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # CUDA binary cache for faster CUDA package builds
    # Note: If CUDA packages fail signature verification, they will be built locally
    substituters = [ "https://cache.nixos.org" "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
    # Keep signature checking enabled for security
    # Unsigned packages will fall back to local builds
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
    # acceptDns option may not exist in all NixOS versions
    # Auth key should be set in secrets.nix for automatic authentication
    # This allows machines to connect to Tailscale on first boot (useful for nixos-anywhere)
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
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Base system packages
  environment.systemPackages = with pkgs; [
    nano
    git
    curl
    wget
    ffmpeg
    net-tools
    lshw
    pciutils

  ];

  # Virtualisation
  virtualisation = {
    docker = {
      enable = true;
    };
  };
}