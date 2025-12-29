{ config, pkgs, lib, ... }:

{

  # Nix configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
    acceptDns = true;
    # Auth key should be set in secrets.nix for automatic authentication
    # This allows machines to connect to Tailscale on first boot (useful for nixos-anywhere)
    # Example in secrets.nix: services.tailscale.authKey = "tskey-auth-...";
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
    nano          # Text editor
    git           # Version control
    curl          # HTTP client
    wget          # File downloader
    ffmpeg        # Video processing
    net-tools     # Network tools
  ];

  # Virtualisation
  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
    };
  };
}