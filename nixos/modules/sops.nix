# SOPS secrets management configuration
# This module sets up sops-nix for encrypted secrets

{ config, lib, ... }:

{
  # Configure sops
  sops = {
    # Default age key file location
    # You'll need to place the age private key at /etc/sops/age/keys.txt on each machine
    # Or use SSH host key (see sops-nix docs)
    age.keyFile = "/etc/sops/age/keys.txt";

    # Note: defaultSopsFile is set per-machine/user in their secrets.nix files
    # Each secrets.nix file specifies its own encrypted secrets.yaml location

    # We're using age keys, not GPG, so don't set gnupg.home
    # If you want to use SSH host keys instead of age, see sops-nix docs
  };
}
