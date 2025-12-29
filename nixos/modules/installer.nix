# Generic installer module for headless WiFi installations
# Auto-connects to WiFi and enables SSH for nixos-anywhere
# Usage: Import this module and set options.wifi and options.sshKeys
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];

  options = {
    installer = {
      wifi = {
        ssid = lib.mkOption {
          type = lib.types.str;
          description = "WiFi SSID to connect to";
        };
        password = lib.mkOption {
          type = lib.types.str;
          description = "WiFi password";
        };
      };
      sshKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "SSH public keys for root access";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "nixos-installer";
        description = "Hostname for the installer";
      };
    };
  };

  config = {

    # Enable SSH so nixos-anywhere can connect
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false; # Key-only
      };
    };

    # SSH keys for root (from options)
    users.users.root.openssh.authorizedKeys.keys = config.installer.sshKeys;

    # Enable NetworkManager for WiFi
    networking.networkmanager.enable = true;
    environment.systemPackages = with pkgs; [ networkmanager ];

    # Auto-connect to WiFi on boot
    systemd.services.wifi-autoconnect = {
      wantedBy = [ "multi-user.target" ];
      after = [ "NetworkManager.service" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # Wait for NetworkManager to be ready
        sleep 5
        # Enable WiFi radio
        ${pkgs.networkmanager}/bin/nmcli radio wifi on
        # Connect to WiFi network
        ${pkgs.networkmanager}/bin/nmcli dev wifi connect "${config.installer.wifi.ssid}" password "${config.installer.wifi.password}" || true
      '';
    };

    # Set hostname
    networking.hostName = config.installer.hostname;
  };
}
