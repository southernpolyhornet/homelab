# AdGuard Home module
# DNS ad-blocker and network-wide tracker/ad blocker
{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    settings = {
      # Web UI configuration - port 80 (matching current setup)
      http = {
        address = "0.0.0.0:80";  # Bind to all interfaces (allows Tailscale access)
        session_ttl = "720h";
      };
      
      # DNS configuration
      dns = {
        bind_hosts = [ "0.0.0.0" ];  # Bind to all interfaces (allows Tailscale access)
        port = 53;
        upstream_dns = [
          "https://dns10.quad9.net/dns-query"
        ];
        bootstrap_dns = [
          "9.9.9.10"
          "149.112.112.10"
          "2620:fe::10"
          "2620:fe::fe:10"
        ];
        upstream_mode = "load_balance";
        fastest_timeout = "1s";
        upstream_timeout = "10s";
        cache_size = 4194304;
        ratelimit = 20;
        refuse_any = true;
        serve_plain_dns = true;
        hostsfile_enabled = true;
      };
      
      # Filters - AdGuard DNS filter enabled
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
      ];
      
      # Filtering settings
      filtering = {
        filtering_enabled = true;
        protection_enabled = true;
        blocking_mode = "default";
        filters_update_interval = 24;
        blocked_response_ttl = 10;
      };
      
      # Query log
      querylog = {
        enabled = true;
        file_enabled = true;
        interval = "2160h";
        size_memory = 1000;
      };
      
      # Statistics
      statistics = {
        enabled = true;
        interval = "24h";
      };
    };
  };

  # Disable systemd-resolved to avoid port 53 conflict
  services.resolved.enable = false;

  # Firewall: Allow AdGuard Home ports
  # Port 53 (DNS) and 80 (web UI)
  networking.firewall = {
    allowedTCPPorts = [ 53 80 ];
    allowedUDPPorts = [ 53 ];
  };
}
