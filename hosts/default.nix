{
  nixpkgs,
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
    lib = import ../lib {
      inherit inputs;
      inherit
        (nixosSystem)
        pkgs
        lib
        config
        ;
    };

    my = {
      inherit
        lib
        modulePresets
        ;
    };

    nixosSystem = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs my;
        flake = self;
      };
      modules = [
        {
          networking.hostName = hostName;
          nixpkgs.hostPlatform = system;
          nixpkgs.overlays = with self.overlays; [
            default
            xdg-dbus-proxy-unicast-signals
          ];
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
