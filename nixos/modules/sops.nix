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
  };
}
