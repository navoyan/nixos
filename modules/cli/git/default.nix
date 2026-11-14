{my, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  my.outOfStoreSymlinks.config.git = my.lib.symlinks.mkSources "cli/git" [
    "./config"
  ];
}
