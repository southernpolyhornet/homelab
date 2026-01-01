{
  description = "My Fleet of Machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.neptune = lib.nixosSystem {
      inherit system;
      modules = [
        ./machines/neptune/hardware-configuration.nix
        ./machines/neptune/configuration.nix
      ];
    };


    # nixosConfigurations.saturn = lib.nixosSystem {
    #   inherit system;
    #   modules = [
    #     ./machines/saturn/hardware-configuration.nix
    #     ./machines/saturn/configuration.nix
    #   ];
    # };
  };
}