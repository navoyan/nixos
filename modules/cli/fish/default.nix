{
  pkgs,
  localLib,
  ...
}: {
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    fishPlugins.tide
    kubectl
  ];

  my.outOfStoreSymlinks.config.fish = localLib.symlinks.mkSources "cli/fish" [
    "./config.fish"
    "./user_functions"
    "./themes"
  ];
}
