{
  pkgs,
  localLib,
  ...
}: {
  environment.systemPackages = [pkgs.wiremix];

  my.outOfStoreSymlinks = {
    config.wiremix = localLib.symlinks.mkSources "cli/wiremix" [
      "./wiremix.toml"
    ];
    data.applications = localLib.symlinks.mkSources "cli/wiremix" [
      "./wiremix.desktop"
    ];
  };
}
