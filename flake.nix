{
  outputs = args: let
    inputs = args // import ./.tack;
  in {
    nixosConfigurations = import ./hosts inputs;
    overlays = import ./overlays inputs;
    packages = import ./pkgs inputs;
  };
}
