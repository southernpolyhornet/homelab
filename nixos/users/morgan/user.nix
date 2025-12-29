# Morgan user configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    (if builtins.pathExists (./. + "/secrets.nix") then ./secrets.nix else {})
  ];

  users.users.morgan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };
}
