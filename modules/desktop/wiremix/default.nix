{
  pkgs,
  my,
  ...
}: {
  environment.systemPackages = [pkgs.wiremix];

  my.outOfStoreSymlinks = {
    config.wiremix = my.lib.symlinks.mkSources "desktop/wiremix" [
      "./wiremix.toml"
    ];
    data.applications = my.lib.symlinks.mkSources "desktop/wiremix" [
      "./wiremix.desktop"
    ];
  };
}
