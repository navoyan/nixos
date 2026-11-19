{
  pkgs,
  my,
  ...
}: let
  inherit (my.lib) symlinks;
in {
  environment.systemPackages = [pkgs.wiremix];

  my.outOfStoreSymlinks = {
    config.wiremix = symlinks.sources "desktop/wiremix" [
      "./wiremix.toml"
    ];
    data.applications = symlinks.sources "desktop/wiremix" [
      "./wiremix.desktop"
    ];
  };
}
