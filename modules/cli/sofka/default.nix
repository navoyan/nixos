{
  flake,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [flake.overlays.sofka];

  environment.systemPackages = [pkgs.sofka];

  my.outOfStoreSymlinks.config.sofka = "cli/sofka";
}
