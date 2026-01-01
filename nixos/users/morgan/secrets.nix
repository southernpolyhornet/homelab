# SOPS secrets configuration for morgan user
# Uses user-specific encrypted file

{ config, lib, ... }:

{
  # Point to user-specific encrypted file (co-located)
  sops.defaultSopsFile = ./secrets.yaml;

  # Define secrets (using nested YAML structure)
  sops.secrets."password_hash" = {};
  sops.secrets."adguard.username" = {};
  sops.secrets."adguard.password_hash" = {};

  # Use the password hash directly (already hashed in YAML)
  users.users.morgan.hashedPassword = lib.removeSuffix "\n" (builtins.readFile config.sops.secrets."password_hash".path);

  # AdGuard Home configuration
  services.adguardhome.settings.users = [
    {
      name = lib.removeSuffix "\n" (builtins.readFile config.sops.secrets."adguard.username".path);
      password = lib.removeSuffix "\n" (builtins.readFile config.sops.secrets."adguard.password_hash".path);
    }
  ];
}
