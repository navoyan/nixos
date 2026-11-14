{my, ...}: let
  inherit (my.lib) symlinks;
in {
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  my.outOfStoreSymlinks.config.git = symlinks.mkSources "cli/git" [
    "./config"
  ];
}
