# SOPS secrets management configuration
# This module sets up sops-nix for encrypted secrets

{ config, lib, ... }:

{
  # Configure sops
  sops = {
    age.keyFile = "/etc/sops/age/keys.txt";
  };
}
