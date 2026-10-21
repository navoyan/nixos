{
  pkgs,
  localLib,
  ...
}: {
  environment.systemPackages = [pkgs.wiremix];

  my.outOfStoreSymlinks = {
    config.wiremix = localLib.symlinks.mkSources "programs/wiremix" [
      "./wiremix.toml"
    ];
    data.applications = localLib.symlinks.mkSources "programs/wiremix" [
      "./wiremix.desktop"
    ];
  };
}
