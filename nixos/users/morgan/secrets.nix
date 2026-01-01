# SOPS secrets configuration for morgan user
# Uses user-specific encrypted file

{ config, lib, ... }:

{
  # Point to user-specific encrypted file (co-located)
  sops.defaultSopsFile = ./secrets.yaml;

  # Define secrets (using nested YAML structure)
  sops.secrets."password_hash" = {
    neededForUsers = true; # Decrypt early so user password is available
  };
  sops.secrets."adguard.username" = {};
  sops.secrets."adguard.password_hash" = {};

  # Use hashedPasswordFile (not hashedPassword) to avoid reading at eval time
  # The file will be created at activation time by SOPS
  users.users.morgan.hashedPasswordFile = config.sops.secrets."password_hash".path;

  # AdGuard Home configuration
  # Note: Services that need actual values (not file paths) require reading at activation time
  # This means nix flake check will need --impure, or we accept that services config
  # can't be fully validated during pure evaluation
  services.adguardhome.settings.users = [
    {
      name = lib.removeSuffix "\n" (builtins.readFile config.sops.secrets."adguard.username".path);
      password = lib.removeSuffix "\n" (builtins.readFile config.sops.secrets."adguard.password_hash".path);
    }
  ];
}
