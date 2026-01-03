# Morgan user configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    # User secrets (auto-generated from secrets.yaml)
    ./secrets.nix
  ];

  users.users.morgan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];  # Removed docker temporarily
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNpMZe1pd6oEEA6eG3H5rah3Nm3kX8gpS8JR4Z9zX2j"
    ];
  };

  # Temporarily enable passwordless sudo for deployment
  # TODO: Remove this after successful deployment and password is working
  security.sudo.wheelNeedsPassword = false;
}
