{
  description = "My Fleet of Machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, disko, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      name = "homelab-devshell";
      packages = with pkgs; [
        age
        sops
        ssh-to-age
        git
        openssh
        jq
        yq-go
        just
        mkpasswd
      ];

      shellHook = ''
        export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
        echo "DevShell ready: $(command -v age-keygen || true)"

        if [ -n "$PS1" ]; then
          PS1="(nix-shell-homelab) $PS1"
        fi
      '';
    };

    nixosConfigurations.neptune = lib.nixosSystem {
      inherit system;
      modules = [
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        ./machines/neptune/disko.nix
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
