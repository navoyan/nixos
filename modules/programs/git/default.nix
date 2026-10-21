{localLib, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  my.outOfStoreSymlinks.config.git = localLib.symlinks.mkSources "programs/git" [
    "./config"
  ];
}
