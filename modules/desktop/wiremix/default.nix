{
  pkgs,
  localLib,
  ...
}: {
  environment.systemPackages = [pkgs.wiremix];

  my.outOfStoreSymlinks = {
    config.wiremix = localLib.symlinks.mkSources "desktop/wiremix" [
      "./wiremix.toml"
    ];
    data.applications = localLib.symlinks.mkSources "desktop/wiremix" [
      "./wiremix.desktop"
    ];
  };
}
