# Steam user configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./secrets.nix
  ];

  users.users.steamuser = {
    isNormalUser = true;
    description = "Steam service user";
    extraGroups = [ "video" "audio" "games" "render" "input" ];
    home = "/home/steamuser";
    createHome = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNpMZe1pd6oEEA6eG3H5rah3Nm3kX8gpS8JR4Z9zX2j"
    ];
  };
}
