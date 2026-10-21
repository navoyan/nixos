{pkgs, ...}: {
  environment.systemPackages = [pkgs.lazygit];

  my.outOfStoreSymlinks.config.lazygit = "programs/lazygit";
}
