_: {
  nixosModules = {
    default.imports = [
      ./coolerdash.nix
      ./vds.nix
    ];
    coolerdash.imports = [
      ./coolerdash.nix
    ];
    vds.imports = [
      ./vds.nix
    ];
  };
}
