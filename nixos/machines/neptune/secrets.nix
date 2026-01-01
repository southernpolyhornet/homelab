# SOPS secrets configuration for neptune
# Uses machine-specific encrypted file

{ config, lib, ... }:

{
  # Define secrets (using nested YAML structure)
  # Each secret specifies its own sopsFile to avoid conflicts
  sops.secrets."tailscale.auth_key" = {
    sopsFile = ./secrets.yaml;
  };

  # Use the decrypted secrets
  services.tailscale.authKeyFile = config.sops.secrets."tailscale.auth_key".path;
}
