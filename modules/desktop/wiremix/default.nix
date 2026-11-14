{
  pkgs,
  my,
  ...
}: let
  inherit (my.lib) symlinks;
in {
  environment.systemPackages = [pkgs.wiremix];

  my.outOfStoreSymlinks = {
    config.wiremix = symlinks.mkSources "desktop/wiremix" [
      "./wiremix.toml"
    ];
    data.applications = symlinks.mkSources "desktop/wiremix" [
      "./wiremix.desktop"
    ];
  };
}
