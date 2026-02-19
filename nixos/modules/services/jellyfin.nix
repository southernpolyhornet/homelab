# Jellyfin Media Server module
# Firewall ports are opened explicitly here (not via services.jellyfin.openFirewall).
{ config, pkgs, lib, ... }:

let
  hasNvidia = (config.hardware.nvidia or {}).package or null != null;
  # Ports Jellyfin uses (match Dashboard → Networking if you change them there)
  jellyfinPorts = {
    http = 8096;
    https = 8920;
    discoveryUdp = [ 1900 7359 ];
  };
in
{
  config = lib.mkIf config.services.jellyfin.enable {
    services.jellyfin = {
      openFirewall = false;

      # NVENC hardware transcoding when NVIDIA is available
      hardwareAcceleration = lib.mkIf hasNvidia {
        enable = true;
        type = "nvenc";
        device = "/dev/nvidia0";
      };
      transcoding.enableHardwareEncoding = lib.mkIf hasNvidia true;
    };

    networking.firewall.allowedTCPPorts = [
      jellyfinPorts.http
      jellyfinPorts.https
    ];
    networking.firewall.allowedUDPPorts = jellyfinPorts.discoveryUdp;
  };
}
