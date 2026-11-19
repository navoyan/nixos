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

  my.outOfStoreSymlinks.config.fish = symlinks.sources "cli/fish" [
    "./config.fish"
    "./user_functions"
    "./themes"
  ];
}
