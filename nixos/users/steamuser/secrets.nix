# SOPS secrets configuration for steamuser
# Uses user-specific encrypted file

{ config, lib, ... }:

{
  # Define secrets (using nested YAML structure)
  sops.secrets."password_hash" = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true; # Decrypt early so user password is available
  };

  # Use hashedPasswordFile (not hashedPassword) to avoid reading at eval time
  # The file will be created at activation time by SOPS
  users.users.steamuser.hashedPasswordFile = config.sops.secrets."password_hash".path;
}
