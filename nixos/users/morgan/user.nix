# Morgan user configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    # User secrets (auto-generated from secrets.yaml)
    ./secrets.nix
  ];

  users.users.morgan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
}
