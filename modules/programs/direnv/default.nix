{
  programs.direnv = {
    enable = true;
    silent = true;
  };

  my.outOfStoreSymlinks.config.direnv = "programs/direnv";
}
