{
  description = "My Fleet of Machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
  in
  {
    # nixosConfigurations.neptune = lib.nixosSystem {
    #   inherit system;
    #   modules = [
    #     # ./machines/neptune/hardware-configuration.nix
    #     ./machines/neptune/configuration.nix
    #   ];
    # };

    nixosConfigurations.saturn = lib.nixosSystem {
      inherit system;
      modules = [
        # ./machines/saturn/hardware-configuration.nix
        ./machines/saturn/configuration.nix
      ];
    };
  };
}