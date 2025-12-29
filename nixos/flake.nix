{
  description = "My Fleet of Machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs { inherit system; };

    # Helper function to create installer (kexec tarball) for any machine
    mkInstaller = machineName:
      let
        # Import secrets (gitignored)
        machineSecrets = if builtins.pathExists ./machines/${machineName}/secrets.nix 
          then import ./machines/${machineName}/secrets.nix 
          else {};
        userSecrets = if builtins.pathExists ./users/morgan/secrets.nix 
          then import ./users/morgan/secrets.nix 
          else {};
        installerConfig = lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/installer.nix
            {
              installer = {
                wifi = machineSecrets.installer.wifi or { ssid = ""; password = ""; };
                sshKeys = userSecrets.users.users.morgan.openssh.authorizedKeys.keys or [];
                hostname = "${machineName}-installer";
              };
            }
          ];
        };
      in
      installerConfig.config.system.build.kexecTarball;
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
        ./machines/saturn/hardware-configuration.nix
        ./machines/saturn/configuration.nix
      ];
    };

    # Custom installer kexec tarballs (WiFi + SSH enabled)
    # Build with: nix build .#installer-<machine-name>
    # Used by nixos-anywhere via --kexec flag
    installer-saturn = mkInstaller "saturn";
    # installer-neptune = mkInstaller "neptune";
  };
}