_: {
  nixosModules = {
    default.imports = [
      ./vds.nix
    ];
    vds.imports = [
      ./vds.nix
    ];
  };
}
