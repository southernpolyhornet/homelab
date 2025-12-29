# Morgan user configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./secrets.nix
  ];

  users.users.morgan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
}
