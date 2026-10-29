{
  nixpkgs,
  jail-nix,
  ...
} @ inputs: let
  inherit
    (builtins)
    mapAttrs
    readDir
    ;

  modulePresets =
    readDir ../modules
    |> mapAttrs (
      name: _:
        import ../modules/${name}/_presets.nix
        |> mapAttrs (_: imports: {inherit imports;})
    );

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
          modulePresets
          localLib
          ;
        user = "narek";
      };
      modules = [
        {
          networking.hostName = hostName;
          nixpkgs.hostPlatform = system;
        }
        modulePresets.core.default
        modulePresets.extensions.default
        ./${directory}/host.nix
      ];
    };
  in
    nixosSystem;
in
  mapAttrs mkHost {
    nixos-desktop = {
      directory = "desktop";
      system = "x86_64-linux";
    };
  }
