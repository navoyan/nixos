{
  nixpkgs,
  jail-nix,
  self,
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
    localLib = import ../lib {
      inherit jail-nix;
      inherit
        (nixosSystem)
        pkgs
        lib
        config
        ;
    };

    nixosSystem = nixpkgs.lib.nixosSystem {
      specialArgs = {
        flake = self;
        inherit
          inputs
          modulePresets
          localLib
          ;
      };
      modules = [
        {
          networking.hostName = hostName;
          nixpkgs.hostPlatform = system;
          nixpkgs.overlays = [self.overlays.default];
        }
        modulePresets.core.default
        ./${directory}/host.nix
      ];
    };
  in
    nixosSystem;
in {
  nixosConfigurations = mapAttrs mkHost {
    nixos-desktop = {
      directory = "desktop";
      system = "x86_64-linux";
    };
  };
}
