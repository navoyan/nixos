{
  pkgs,
  localLib,
  ...
}: {
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    fishPlugins.tide
  ];

  my.outOfStoreSymlinks.config.fish = localLib.symlinks.mkSources "programs/fish" [
    "./config.fish"
    "./user_functions"
    "./themes"
  ];
}
