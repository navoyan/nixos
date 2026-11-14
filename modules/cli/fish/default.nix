{
  pkgs,
  my,
  ...
}: let
  inherit (my.lib) symlinks;
in {
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    fishPlugins.tide
    kubectl
  ];

  my.outOfStoreSymlinks.config.fish = symlinks.mkSources "cli/fish" [
    "./config.fish"
    "./user_functions"
    "./themes"
  ];
}
