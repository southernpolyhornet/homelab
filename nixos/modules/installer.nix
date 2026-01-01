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
        description = "Hostname for the installer (should be <machine-name>-installer)";
      };
    };
  };

  config = {
    # Include firmware for WiFi hardware support
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = [ pkgs.linux-firmware ];

    # Enable SSH so nixos-anywhere can connect
    services.openssh = {
      enable = true;
      openFirewall = true;  # Ensure SSH is reachable
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = false; # Key-only
      };
    };

    # SSH keys for root (from options)
    users.users.root.openssh.authorizedKeys.keys = config.installer.sshKeys;

    # Enable NetworkManager for WiFi
    # But ignore wired interfaces so they don't get reset during kexec handoff
    networking.networkmanager = {
      enable = true;
      # Don't manage wired interfaces - preserve the connection nixos-anywhere is using
      unmanaged = [
        "interface-name:en*"
        "interface-name:eth*"
        "interface-name:ens*"
        "interface-name:enp*"
      ];
      # Declarative WiFi profile (better than systemd service)
      ensureProfiles.profiles."installer-wifi" = {
        connection = {
          id = "installer-wifi";
          type = "wifi";
          autoconnect = true;
          autoconnect-priority = 10;
        };
        wifi = {
          mode = "infrastructure";
          ssid = config.installer.wifi.ssid;
        };
        "wifi-security" = {
          key-mgmt = "wpa-psk";
          psk = config.installer.wifi.password;
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          method = "auto";
        };
      };
    };

    # Set hostname (override any defaults from netboot-minimal)
    networking.hostName = lib.mkOverride 1000 config.installer.hostname;
  };
}
