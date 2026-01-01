# SOPS secrets configuration for neptune
# Uses machine-specific encrypted file

{ config, lib, ... }:

{
  # Point to machine-specific encrypted file (co-located)
  sops.defaultSopsFile = ./secrets.yaml;

  # Define secrets (using nested YAML structure)
  sops.secrets."tailscale.auth_key" = {};

  # Use the decrypted secrets
  services.tailscale.authKeyFile = config.sops.secrets."tailscale.auth_key".path;
}
