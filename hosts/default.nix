{
  nixpkgs,
  jail-nix,
  ...
} @ inputs: let
  importRootModule = rootMod: import ../modules/${rootMod}/_meta.nix;
  nixosModules = {
    core = importRootModule "core";
    extensions = importRootModule "extensions";
    hardware = importRootModule "hardware";
    cli = importRootModule "cli";
    desktop = importRootModule "desktop";
  };

  mkHost = hostName: {
    directory,
    system,
  }: let
    pkgsQt610 = import inputs.nixpkgs-qt6-10 {
      inherit system;
      overlays = [
        inputs.nur.repos.ilya-fedin.overlays.qt6ct
      ];
    };

    localLib = import ../lib {
      inherit jail-nix;
      inherit (nixosSystem) pkgs lib config;
    };

    nixosSystem = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          pkgsQt610
          nixosModules
          localLib
          ;
        user = "narek";
      };
      modules = [
        {
          networking.hostName = hostName;
          nixpkgs.hostPlatform = system;
        }
        nixosModules.core.default
        nixosModules.extensions.default
        ./${directory}/host.nix
      ];
    };
  in
    nixosSystem;
in
  builtins.mapAttrs mkHost {
    nixos-desktop = {
      directory = "desktop";
      system = "x86_64-linux";
    };
  }
