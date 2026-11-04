{
  outputs = args: let
    inputs = args // import ./.tack;
    output = file: import file inputs;
  in {
    inherit (output ./hosts) nixosConfigurations;
    inherit (output ./overlays) overlays;
    inherit (output ./pkgs) packages;
  };
}
