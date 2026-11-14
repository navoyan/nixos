{
  pkgs,
  my,
  ...
}: {
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    fishPlugins.tide
    kubectl
  ];

  my.outOfStoreSymlinks.config.fish = my.lib.symlinks.mkSources "cli/fish" [
    "./config.fish"
    "./user_functions"
    "./themes"
  ];
}
