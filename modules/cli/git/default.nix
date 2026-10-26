{localLib, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  my.outOfStoreSymlinks.config.git = localLib.symlinks.mkSources "cli/git" [
    "./config"
  ];
}
