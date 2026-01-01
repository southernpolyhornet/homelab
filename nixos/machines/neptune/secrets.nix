# SOPS secrets configuration for neptune
# Uses machine-specific encrypted file

{ config, lib, ... }:

{
  # Point to machine-specific encrypted file (co-located)
  sops.defaultSopsFile = ./secrets.yaml;

  # Define secrets (using nested YAML structure)
  sops.secrets."tailscale.auth_key" = {};
  sops.secrets."ssh.authorized_keys" = {};

  # Use the decrypted secrets
  services.tailscale.authKeyFile = config.sops.secrets."tailscale.auth_key".path;

  # Parse SSH keys from YAML array
  users.users.morgan.openssh.authorizedKeys.keys =
    let
      keysFile = config.sops.secrets."ssh.authorized_keys".path;
      keysContent = lib.removeSuffix "\n" (builtins.readFile keysFile);
      # Parse YAML array format: - key1\n- key2
      lines = lib.splitString "\n" keysContent;
      extractKey = line: lib.removePrefix "    - " (lib.removePrefix "  - " (lib.removePrefix "- " line));
    in
      map extractKey (lib.filter (line: line != "" && (lib.hasPrefix "    - " line || lib.hasPrefix "  - " line || lib.hasPrefix "- " line)) lines);
}
